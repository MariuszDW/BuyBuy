//
//  ExampleMigration_v1_to_v2.swift
//  BuyBuy
//
//  Created by MDW on 21/07/2025.
//

import Foundation
import CoreData

final class ExampleMigration_v1_to_v2: MigrationStepProtocol {
    let fromVersion = "Model_v1"
    let toVersion = "Model_v2"
    
    func shouldMigrate(storeURL: URL, to currentModel: NSManagedObjectModel) -> Bool { // TODO: ta funkcja moglaby byc w
        // Checking whether the model in the store file requires migration to the current model.
        let metadata = DataModelMigrator.metadataForStore(at: storeURL)
        let compatible = currentModel.isConfiguration(withName: nil, compatibleWithStoreMetadata: metadata)
        
        // Check if this is the version that needs to be migrated from.
        // let storeVersion = (metadata["NSStoreModelVersionIdentifiers"] as? [String])?.first

        return !compatible // || storeVersion == fromVersion
    }
    
    func migrateObjects(from oldContext: NSManagedObjectContext, to newContext: NSManagedObjectContext) throws {
        let itemFetch: NSFetchRequest<ShoppingItemEntity> = ShoppingItemEntity.fetchRequest()
        let oldItems = try oldContext.fetch(itemFetch)
        for oldItem in oldItems {
            // Example of a migration.
            let newItem = NSEntityDescription.insertNewObject(forEntityName: "ShoppingItemEntity", into: newContext)
            newItem.setValue(oldItem.value(forKey: "name"), forKey: "name")
            newItem.setValue(oldItem.value(forKey: "quantity"), forKey: "quantity")
            newItem.setValue(true, forKey: "isMigrated")
        }
        
        let cardFetch: NSFetchRequest<LoyaltyCardEntity> = LoyaltyCardEntity.fetchRequest()
        let oldICards = try oldContext.fetch(cardFetch)
        for oldICard in oldICards {
            print("Migration - card.name: \(String(describing: oldICard.value(forKey: "name")))")
        }
    }
}
