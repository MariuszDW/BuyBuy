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
    
    private let onChange: @Sendable @MainActor () async -> Void
    
    init(maxTokenHistory: Int = 8,
         throttle: TimeInterval = 1.0,
         onChange: @escaping @Sendable @MainActor () async -> Void) {
        self.maxTokenHistory = maxTokenHistory
        self.anonymousReloadThrottleInterval = throttle
        self.onChange = onChange
    }
    
    deinit {
        cancellable?.cancel()
    }
    
    func startObserving(forceInitialReload: Bool = true) {
        guard cancellable == nil else { return }
        observeRemoteChanges()
    }
    
    func stopObserving() {
        guard cancellable != nil else { return }
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
                guard let self = self else { return }
                
                let onChange = self.onChange
                
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
                    
                    print("New historyToken, reloading...")
                    Task { @MainActor in await onChange() }
                    
                } else {
                    let now = Date()
                    if let last = self.lastAnonymousReloadDate,
                       now.timeIntervalSince(last) < self.anonymousReloadThrottleInterval {
                        print("Skipping anonymous reload — throttled")
                        return
                    }
                    
                    self.lastAnonymousReloadDate = now
                    print("Reloading on anonymous change")
                    Task { @MainActor in await onChange() }
                }
            }
    }
}
