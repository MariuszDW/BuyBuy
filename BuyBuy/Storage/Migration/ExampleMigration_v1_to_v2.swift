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
    
    func shouldMigrate(storeURL: URL, to currentModel: NSManagedObjectModel) -> Bool {
        // Checking whether the model in the store file requires migration to the current model.
        guard let metadata = try? NSPersistentStoreCoordinator.metadataForPersistentStore(ofType: NSSQLiteStoreType, at: storeURL),
              !currentModel.isConfiguration(withName: nil, compatibleWithStoreMetadata: metadata) else {
            return false
        }
        return true
    }
    
    func performMigration(storeURL: URL) throws -> URL {
        // 1. Loading the old model (Model_v1.momd).
        guard let oldModelURL = Bundle.main.url(forResource: fromVersion, withExtension: "momd"),
              let oldModel = NSManagedObjectModel(contentsOf: oldModelURL) else {
            throw NSError(domain: "ExampleMigration_v1_to_v2", code: 1,
                          userInfo: [NSLocalizedDescriptionKey: "Cannot load old model \(fromVersion)"])
        }
        
        // 2. Creating NSPersistentStoreCoordinator for the old model and adding the store in read-only mode.
        let oldPSC = NSPersistentStoreCoordinator(managedObjectModel: oldModel)
        try oldPSC.addPersistentStore(ofType: NSSQLiteStoreType,
                                     configurationName: nil,
                                     at: storeURL,
                                     options: [NSReadOnlyPersistentStoreOption: true])
        
        let oldContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        oldContext.persistentStoreCoordinator = oldPSC
        
        // 3. Loading the new model (current).
        guard let newModel = NSManagedObjectModel.mergedModel(from: nil) else {
            throw NSError(domain: "ExampleMigration_v1_to_v2", code: 2,
                          userInfo: [NSLocalizedDescriptionKey: "Cannot load new model"])
        }
        
        // 4. Creating NSPersistentStoreCoordinator for the new model, using a temporary file.
        let originalFileName = storeURL.lastPathComponent // e.g. "CloudStore.sqlite"
        let tempFileName = "Temp" + originalFileName // e.g. "TempCloudStore.sqlite"
        let tempNewStoreURL = storeURL.deletingLastPathComponent().appendingPathComponent(tempFileName)
        if FileManager.default.fileExists(atPath: tempNewStoreURL.path) {
            try FileManager.default.removeItem(at: tempNewStoreURL)
        }
        
        let newPSC = NSPersistentStoreCoordinator(managedObjectModel: newModel)
        try newPSC.addPersistentStore(ofType: NSSQLiteStoreType,
                                     configurationName: nil,
                                     at: tempNewStoreURL,
                                     options: nil)
        
        let newContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        newContext.persistentStoreCoordinator = newPSC
        
        // 5. Fetching the old data and transferring it into the new context.
        try oldContext.performAndWait {
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "ShoppingItem")
            let oldItems = try oldContext.fetch(fetchRequest)
            
            try newContext.performAndWait {
                for oldItem in oldItems {
                    let newItem = NSEntityDescription.insertNewObject(forEntityName: "ShoppingItem", into: newContext)
                    
                    // Example of copying properties (adjust as needed for the model)
                    newItem.setValue(oldItem.value(forKey: "name"), forKey: "name")
                    newItem.setValue(oldItem.value(forKey: "quantity"), forKey: "quantity")
                    
                    // Example of a new attribute in model v2
                    newItem.setValue(true, forKey: "isMigrated")
                }
                
                if newContext.hasChanges {
                    try newContext.save()
                }
            }
        }
        
        // 6. Replacing the original file with the new migrated file.
        try FileManager.default.removeItem(at: storeURL)
        try FileManager.default.moveItem(at: tempNewStoreURL, to: storeURL)
        
        return tempNewStoreURL
    }
}
