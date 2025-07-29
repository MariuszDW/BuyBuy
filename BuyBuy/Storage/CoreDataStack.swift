//
//  CoreDataStack.swift
//  BuyBuy
//
//  Created by MDW on 21/05/2025.
//

import Foundation
import CoreData
import CloudKit

final class CoreDataStack: @unchecked Sendable, CoreDataStackProtocol {
    static let isCloudKey = "isCloud"
    let container: NSPersistentContainer
    let isCloud: Bool
    
    static func storeURL(useCloud: Bool) -> URL {
        guard let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: AppConstants.appGroupID) else {
            fatalError("Cannot find App Group directory")
        }
        
        try? FileManager.default.createDirectory(at: containerURL, withIntermediateDirectories: true)
        
        let storeFileName = useCloud ? AppConstants.cloudStoreFileName : AppConstants.localStoreFileName
        return containerURL.appendingPathComponent(storeFileName)
    }
    
    init(useCloudSync: Bool) {
        self.isCloud = useCloudSync
        let modelName = AppConstants.coreDataModelName
        
        if useCloudSync {
            container = NSPersistentCloudKitContainer(name: modelName)
        } else {
            container = NSPersistentContainer(name: modelName)
        }
        
        let storeURL = CoreDataStack.storeURL(useCloud: useCloudSync)
        
        if let description = container.persistentStoreDescriptions.first {
            description.url = storeURL
            
            // Enable lightweight migration.
            description.shouldMigrateStoreAutomatically = true
            description.shouldInferMappingModelAutomatically = true
            
            if useCloudSync {
                description.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: AppConstants.iCloudContainerID)
                description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
                description.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
            } else {
                description.cloudKitContainerOptions = nil
            }
        }
        
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Core Data failed to load: \(error.localizedDescription)")
            } else {
                print("Core Data store loaded: \(description.url?.absoluteString ?? "unknown URL")")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        container.viewContext.userInfo[Self.isCloudKey] = useCloudSync
    }
    
    var viewContext: NSManagedObjectContext {
        container.viewContext
    }
    
    func newBackgroundContext() -> NSManagedObjectContext {
        let context = container.newBackgroundContext()
        context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        context.transactionAuthor = "SaveQueue"
        context.userInfo[Self.isCloudKey] = isCloud
        return context
    }
}
