//
//  PersistentStoreChangeObserver.swift
//  BuyBuy
//
//  Created by MDW on 19/06/2025.
//

import Foundation
import Combine
import CoreData

final class PersistentStoreChangeObserver {
    private var cancellable: AnyCancellable?
    private var processedTokens: [NSPersistentHistoryToken] = []
    private let maxTokenHistory: Int
    private var lastAnonymousReloadDate: Date?
    private let anonymousReloadThrottleInterval: TimeInterval
    
    private let coreDataStack: CoreDataStackProtocol
    private let onChange: @Sendable @MainActor () async -> Void
    
    init(coreDataStack: CoreDataStackProtocol,
         maxTokenHistory: Int = 8,
         throttle: TimeInterval = 1.0,
         onChange: @escaping @Sendable @MainActor () async -> Void) {
        self.coreDataStack = coreDataStack
        self.maxTokenHistory = maxTokenHistory
        self.anonymousReloadThrottleInterval = throttle
        self.onChange = onChange
    }
    
    deinit {
        stopObserving()
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
        processedTokens.removeAll()
    }
    
    private func observeRemoteChanges() {
        print("PersistentStoreChangeObserver.observeRemoteChanges() called")
        cancellable = NotificationCenter.default
            .publisher(for: .NSPersistentStoreRemoteChange)
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] notification in
                guard let self else { return }
                
                let handleChange = { [coreDataStack = self.coreDataStack, onChange = self.onChange] in
                    let bgContext = coreDataStack.newBackgroundContext()
                    
                    Task.detached { [bgContext] in
                        await bgContext.perform {
                            do {
                                try Deduplicator.deduplicateAndMergeAllEntities(in: bgContext)
                            } catch {
                                print("Deduplication failed: \(error)")
                            }
                        }
                        
                        Task { @MainActor in
                            await onChange()
                        }
                    }
                }
                
                if let userInfo = notification.userInfo,
                   let newToken = userInfo["historyToken"] as? NSPersistentHistoryToken {
                    
                    if self.processedTokens.contains(where: { $0.isEqual(newToken) }) {
                        print("Ignoring duplicate historyToken")
                        return
                    }
                    
                    self.processedTokens.append(newToken)
                    if self.processedTokens.count > self.maxTokenHistory {
                        self.processedTokens.removeFirst()
                    }
                    
                    print("New historyToken, running deduplication...")
                    handleChange()
                    
                } else {
                    let now = Date.now
                    if let last = self.lastAnonymousReloadDate,
                       now.timeIntervalSince(last) < self.anonymousReloadThrottleInterval {
                        print("Skipping anonymous reload — throttled")
                        return
                    }
                    
                    self.lastAnonymousReloadDate = now
                    print("Anonymous change detected, running deduplication...")
                    handleChange()
                }
            }
    }
}
