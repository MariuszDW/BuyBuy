//
//  MockCoreDataStack.swift
//  BuyBuy
//
//  Created by MDW on 25/06/2025.
//

import Foundation
import CoreData

final class MockCoreDataStack: CoreDataStackProtocol, @unchecked Sendable {
    func fetchRemoteChanges() async {
    }
    
    var privateCloudPersistentStore: NSPersistentStore? {
        return nil
    }
    
    var sharedCloudPersistentStore: NSPersistentStore? {
        return nil
    }
    
    var devicePersistentStore: NSPersistentStore? {
        return nil
    }
    
    var isCloud: Bool
    let container: NSPersistentContainer
    let viewContext: NSManagedObjectContext
    private(set) lazy var saveQueue = SaveQueue(newContext: { NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType) })

    init() {
        isCloud = false
        container = NSPersistentContainer(name: "MockContainer", managedObjectModel: NSManagedObjectModel())
        viewContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    }

    func newBackgroundContext() -> NSManagedObjectContext {
        NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
    }

    func teardown() async {
        // none
    }
}
