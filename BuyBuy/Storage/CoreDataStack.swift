//
//  CoreDataStack.swift
//  BuyBuy
//
//  Created by MDW on 21/05/2025.
//

import Foundation
import CoreData
import CloudKit

actor SaveQueue {
    private let newContext: () -> NSManagedObjectContext
    
    init(newContext: @escaping () -> NSManagedObjectContext) {
        self.newContext = newContext
    }
    
    func performSave(_ block: @escaping @Sendable (NSManagedObjectContext) throws -> Void) async throws {
        let context = newContext()
        return try await withCheckedThrowingContinuation { continuation in
            context.perform {
                do {
                    try block(context)
                    
                    if context.hasChanges {
                        let now = Date.now
                        
                        for object in context.insertedObjects.union(context.updatedObjects) {
                            if object.entity.attributesByName.keys.contains("updatedAt") {
                                object.setValue(now, forKey: "updatedAt")
                            }
                        }
                        
                        try context.save()
                    }
                    
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

final class CoreDataStack: @unchecked Sendable, CoreDataStackProtocol {
    static let isCloudKey = "isCloud"
    static let author = "BuyBuyAuthor"

    let container: NSPersistentContainer
    let isCloud: Bool

    private(set) var privateCloudPersistentStore: NSPersistentStore?
    private(set) var sharedCloudPersistentStore: NSPersistentStore?
    private(set) var devicePersistentStore: NSPersistentStore?

    private(set) lazy var saveQueue: SaveQueue = SaveQueue(newContext: { [weak self] in
        self?.newBackgroundContext() ?? { fatalError("CoreDataStack deallocated") }()
    })

    // MARK: - Init
    init(useCloudSync: Bool) {
        self.isCloud = useCloudSync

        if useCloudSync {
            let cloudContainer = NSPersistentCloudKitContainer(name: AppConstants.coreDataModelName)
            self.container = cloudContainer

            // Private store.
            let privateDesc = NSPersistentStoreDescription(url: CoreDataStack.storeURL(fileName: AppConstants.privateCloudStoreFileName))
            Self.configureCloudStore(privateDesc, scope: .private)

            // Shared store.
            let sharedDesc = NSPersistentStoreDescription(url: CoreDataStack.storeURL(fileName: AppConstants.sharedCloudStoreFileName))
            Self.configureCloudStore(sharedDesc, scope: .shared)

            cloudContainer.persistentStoreDescriptions = [privateDesc, sharedDesc]

            loadStoresAndTrack(cloudContainer)
        } else {
            // Device store.
            let deviceContainer = NSPersistentContainer(name: AppConstants.coreDataModelName)
            self.container = deviceContainer
            
            let deviceDesc = NSPersistentStoreDescription(url: CoreDataStack.storeURL(fileName: AppConstants.localStoreFileName))
            deviceDesc.shouldMigrateStoreAutomatically = true
            deviceDesc.shouldInferMappingModelAutomatically = true
            deviceDesc.cloudKitContainerOptions = nil
            
            deviceContainer.persistentStoreDescriptions = [deviceDesc]

            loadStoresAndTrack(deviceContainer)
        }

        // Common settings.
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = UUIDMergePolicy()
        container.viewContext.userInfo[Self.isCloudKey] = useCloudSync
    }

    func fetchRemoteChanges() async {
        guard isCloud else { return }
        
        guard let privateStore = privateCloudPersistentStore,
              let sharedStore = sharedCloudPersistentStore else {
            return
        }
        
        do {
            try await fetchChanges(for: privateStore, scope: .private)
        } catch {
            print("Failed to fetch remote changes from CloudKit for private store: \(error)")
        }
        
        do {
            try await fetchChanges(for: sharedStore, scope: .shared)
        } catch {
            print("Failed to fetch remote changes from CloudKit for shared store: \(error)")
        }
        
        // Notify CoreData observers.
        NotificationCenter.default.post(
            name: .NSPersistentStoreRemoteChange,
            object: container.persistentStoreCoordinator
        )
    }
    
    private func fetchChanges(for store: NSPersistentStore, scope: CKDatabase.Scope) async throws {
        let container = CKContainer(identifier: AppConstants.iCloudContainerID)
        let database: CKDatabase = (scope == .private) ? container.privateCloudDatabase : container.sharedCloudDatabase
        
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            let operation = CKFetchDatabaseChangesOperation(previousServerChangeToken: nil)
            operation.fetchAllChanges = true
            // operation.recordZoneWithIDChangedBlock = { _ in }
            operation.fetchDatabaseChangesResultBlock = { result in
                switch result {
                case .failure(let error):
                    continuation.resume(throwing: error)
                case .success:
                    continuation.resume()
                }
            }
            database.add(operation)
        }
    }
    
    // MARK: - Helpers
    private static func configureCloudStore(_ desc: NSPersistentStoreDescription, scope: CKDatabase.Scope) {
        desc.shouldMigrateStoreAutomatically = true
        desc.shouldInferMappingModelAutomatically = true
        desc.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        desc.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        
        let options = NSPersistentCloudKitContainerOptions(containerIdentifier: AppConstants.iCloudContainerID)
        options.databaseScope = scope
        desc.cloudKitContainerOptions = options
    }

    private func loadStoresAndTrack(_ container: NSPersistentContainer) {
        var loadedStoresCount = 0
        let totalStores = container.persistentStoreDescriptions.count

        container.loadPersistentStores { [weak self] desc, error in
            guard let self = self else { return }

            if let error = error {
                print("Failed to load store: \(error)")
                return
            }

            loadedStoresCount += 1
            print("Store loaded: \(desc.url?.lastPathComponent ?? "unknown")")

            if let scope = desc.cloudKitContainerOptions?.databaseScope {
                switch scope {
                case .private:
                    self.privateCloudPersistentStore = container.persistentStoreCoordinator.persistentStore(for: desc.url!)
                    print("Private store loaded")
                case .shared:
                    self.sharedCloudPersistentStore = container.persistentStoreCoordinator.persistentStore(for: desc.url!)
                    print("Shared store loaded")
                default: break
                }
            } else {
                self.devicePersistentStore = container.persistentStoreCoordinator.persistentStore(for: desc.url!)
                print("Device store loaded")
            }

            // --- Deduplicate after all stores are loaded ---
            if loadedStoresCount == totalStores {
                let context = container.viewContext
                Task {
                    do {
                        try Deduplicator.deduplicate(in: context)
                        print("Deduplication done")
                    } catch {
                        print("Deduplication failed: \(error)")
                    }
                }
            }
        }
    }

    // MARK: - Contexts
    var viewContext: NSManagedObjectContext { container.viewContext }

    func newBackgroundContext() -> NSManagedObjectContext {
        let context = container.newBackgroundContext()
        context.mergePolicy = UUIDMergePolicy()
        context.transactionAuthor = Self.author
        context.automaticallyMergesChangesFromParent = true
        context.userInfo[Self.isCloudKey] = isCloud
        return context
    }

    // MARK: - Utilities
    static func storeURL(fileName: String) -> URL {
        guard let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: AppConstants.appGroupID) else {
            fatalError("Cannot find App Group directory")
        }
        try? FileManager.default.createDirectory(at: containerURL, withIntermediateDirectories: true)
        return containerURL.appending(path: fileName, directoryHint: .notDirectory)
    }

    func loadPersistentStores() async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            container.loadPersistentStores { _, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }

    func teardown() async {
        let coordinator = container.persistentStoreCoordinator
        await withCheckedContinuation { continuation in
            coordinator.perform {
                for store in coordinator.persistentStores {
                    do {
                        try coordinator.remove(store)
                        if let url = store.url, store.type != NSInMemoryStoreType {
                            try coordinator.destroyPersistentStore(at: url, ofType: NSSQLiteStoreType, options: store.options)
                        }
                    } catch {
                        print("Failed to teardown persistent store: \(error)")
                    }
                }
                continuation.resume()
            }
        }
    }
}
