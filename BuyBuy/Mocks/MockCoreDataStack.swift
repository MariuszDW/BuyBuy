//
//  MockCoreDataStack.swift
//  BuyBuy
//
//  Created by MDW on 25/06/2025.
//

import Foundation
import CoreData

final class MockCoreDataStack: @unchecked Sendable, CoreDataStackProtocol {
    let viewContext: NSManagedObjectContext
    private let mockPersistentStoreCoordinator: NSPersistentStoreCoordinator
    
    private(set) lazy var saveQueue = SaveQueue(newContext: { [unowned self] in
        self.newBackgroundContext()
    })
    
    init() {
        let managedObjectModel = NSManagedObjectModel()
        mockPersistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        viewContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        viewContext.persistentStoreCoordinator = mockPersistentStoreCoordinator
    }
    
    func newBackgroundContext() -> NSManagedObjectContext {
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.persistentStoreCoordinator = mockPersistentStoreCoordinator
        return context
    }
}
