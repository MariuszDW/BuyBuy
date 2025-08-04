//
//  ExampleMigration_v1_to_v2.swift
//  BuyBuy
//
//  Created by MDW on 21/07/2025.
//

import Foundation
import CoreData

final class DataMigration_v1_to_v2: MigrationStepProtocol {
    let fromVersion = "Model"
    let toVersion = "Model_v2"
    
    func shouldMigrate(storeURL: URL, to currentModel: NSManagedObjectModel) -> Bool { // TODO: ta funkcja moglaby byc w
        // Checking whether the model in the store file requires migration to the current model.
        guard let metadata = try? NSPersistentStoreCoordinator.metadataForPersistentStore(ofType: NSSQLiteStoreType, at: storeURL),
              !currentModel.isConfiguration(withName: nil, compatibleWithStoreMetadata: metadata) else {
            return false
        }
        return true
    }
    
    func migrateObjects(from oldContext: NSManagedObjectContext, to newContext: NSManagedObjectContext) throws {
        let fetch = NSFetchRequest<NSManagedObject>(entityName: "ShoppingItem")
        let oldItems = try oldContext.fetch(fetch)
        
        for oldItem in oldItems {
            print("Migration - item.name: \(String(describing: oldItem.value(forKey: "name")))")
            // Example of a migration.
//            let newItem = NSEntityDescription.insertNewObject(forEntityName: "ShoppingItem", into: newContext)
//            newItem.setValue(oldItem.value(forKey: "name"), forKey: "name")
//            newItem.setValue(oldItem.value(forKey: "quantity"), forKey: "quantity")
//            newItem.setValue(true, forKey: "isMigrated")
        }
    }
}
