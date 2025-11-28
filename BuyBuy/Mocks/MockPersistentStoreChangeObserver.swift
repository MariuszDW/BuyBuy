//
//  MockPersistentStoreChangeObserver.swift
//  BuyBuy
//
//  Created by MDW on 09/09/2025.
//

import Foundation

final class MockPersistentStoreChangeObserver: PersistentStoreChangeObserverProtocol {
    func startObserving() {}
    
    func stopObserving() {}
    
    func addObserver(_ observer: AnyObject, onChange: @escaping @Sendable @MainActor () async -> Void) {}
    
    func removeObserver(_ observer: AnyObject) {}
    
    func getObserversAndBlocks() -> [(AnyObject, @Sendable @MainActor () async -> Void)] {
        return []
    }
}
