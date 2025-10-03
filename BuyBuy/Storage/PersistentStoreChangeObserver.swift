//
//  PersistentStoreChangeObserver.swift
//  BuyBuy
//
//  Created by MDW on 19/06/2025.
//

import Foundation
import CoreData
import Combine

final class PersistentStoreChangeObserver: PersistentStoreChangeObserverProtocol {
    private static let historyTokenPrefix = "HistoryToken_"
    private var cancellable: AnyCancellable?
    private let coreDataStack: CoreDataStackProtocol

    private var handlerBlocks: [ObjectIdentifier: WeakHandler] = [:]

    init(coreDataStack: CoreDataStackProtocol) {
        self.coreDataStack = coreDataStack
    }

    deinit {
        stopObserving()
    }

    // MARK: - Observer Management

    func addObserver(_ observer: AnyObject, onChange: @escaping @MainActor () async -> Void) {
        let id = ObjectIdentifier(observer)
        handlerBlocks[id] = WeakHandler(observer: observer, block: onChange)
    }

    func removeObserver(_ observer: AnyObject) {
        let id = ObjectIdentifier(observer)
        handlerBlocks.removeValue(forKey: id)
    }

    func getObserversAndBlocks() -> [(AnyObject, @MainActor () async -> Void)] {
        var result: [(AnyObject, @MainActor () async -> Void)] = []
        for (id, weakHandler) in handlerBlocks {
            if let observer = weakHandler.observer {
                result.append((observer, weakHandler.block))
            } else {
                handlerBlocks.removeValue(forKey: id)
            }
        }
        return result
    }

    func startObserving() {
        guard cancellable == nil else { return }
        observeRemoteChanges()
    }

    func startObserving(timeout: TimeInterval) async {
        startObserving()
        try? await Task.sleep(for: .seconds(timeout))
        stopObserving()
    }

    func stopObserving() {
        cancellable?.cancel()
        cancellable = nil
    }

    // MARK: - Private

    private func observeRemoteChanges() {
        guard let stack = coreDataStack as? CoreDataStack else { return }
        let coordinator = stack.container.persistentStoreCoordinator
        let container = stack.container

        var cancellables: [AnyCancellable] = []

        let remoteChange = NotificationCenter.default.publisher(for: .NSPersistentStoreRemoteChange, object: coordinator)
            //.debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] notification in
                self?.handleRemoteChange(notification)
            }
        cancellables.append(remoteChange)

        let cloudKitEvent = NotificationCenter.default.publisher(for: NSPersistentCloudKitContainer.eventChangedNotification, object: container)
            //.debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] notification in
                self?.handleCloudKitEvent(notification)
            }
        cancellables.append(cloudKitEvent)

        cancellable = AnyCancellable {
            cancellables.forEach { $0.cancel() }
        }
    }

    private func handleRemoteChange(_ notification: Notification) {
        guard let stack = coreDataStack as? CoreDataStack else { return }

        let storeUUIDs: [String] = {
            if let storeUUID = notification.userInfo?[NSStoreUUIDKey] as? String {
                return [storeUUID]
            } else {
                return stack.container.persistentStoreCoordinator.persistentStores.compactMap { $0.identifier }
            }
        }()

        let observersAndBlocks = getObserversAndBlocks().map(\.1)

        for storeUUID in storeUUIDs {
            let bgContext = stack.newBackgroundContext()
            bgContext.perform {
                let lastToken = Self.historyToken(for: storeUUID)
                let request = NSPersistentHistoryChangeRequest.fetchHistory(after: lastToken)

                if let store = stack.container.persistentStoreCoordinator.persistentStores.first(where: { $0.identifier == storeUUID }) {
                    request.affectedStores = [store]
                }
                
                // let historyFetchRequest = NSPersistentHistoryTransaction.fetchRequest!
                // historyFetchRequest.predicate = NSPredicate(format: "author != %@", CoreDataStack.author)
                // request.fetchRequest = historyFetchRequest
                
                let result = try? bgContext.execute(request) as? NSPersistentHistoryResult
                guard let transactions = result?.result as? [NSPersistentHistoryTransaction], !transactions.isEmpty else { return }
                // let transactions = result?.result as? [NSPersistentHistoryTransaction] ?? []

                try? Deduplicator.deduplicate(from: transactions, in: bgContext)

                Task { @MainActor in
                    for block in observersAndBlocks {
                        await block()
                    }
                }

                if let newToken = transactions.last?.token {
                    Self.updateHistoryToken(for: storeUUID, newToken: newToken)
                }
            }
        }
    }

    private func handleCloudKitEvent(_ notification: Notification) {
        guard let event = notification.userInfo?[NSPersistentCloudKitContainer.eventNotificationUserInfoKey]
                as? NSPersistentCloudKitContainer.Event else {
            return
        }

        if let error = event.error as NSError?,
           error.domain == NSCocoaErrorDomain,
           error.code == NSPersistentHistoryTokenExpiredError {
            let storeID = event.storeIdentifier
            AppLogger.general.warning("History token expired – clearing token for store \(storeID, privacy: .public)")
            clearHistoryToken(for: storeID)
        }

        let observersAndBlocks = getObserversAndBlocks().map(\.1)
        
        Task { @MainActor in
            for block in observersAndBlocks {
                await block()
            }
        }
    }

    // MARK: - History token helpers
    
    private func clearHistoryToken(for storeUUID: String) {
        let key = Self.historyTokenPrefix + storeUUID
        UserDefaults.standard.removeObject(forKey: key)
        AppLogger.general.info("Removed history token for \(key, privacy: .public)")
    }

    private static func historyToken(for storeUUID: String) -> NSPersistentHistoryToken? {
        let key = Self.historyTokenPrefix + storeUUID
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSPersistentHistoryToken.self, from: data)
    }

    private static func updateHistoryToken(for storeUUID: String, newToken: NSPersistentHistoryToken) {
        let key = Self.historyTokenPrefix + storeUUID
        if let data = try? NSKeyedArchiver.archivedData(withRootObject: newToken, requiringSecureCoding: true) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}

// MARK: - WeakHandler

private class WeakHandler {
    weak var observer: AnyObject?
    let block: @MainActor () async -> Void

    init(observer: AnyObject, block: @escaping @MainActor () async -> Void) {
        self.observer = observer
        self.block = block
    }
}
