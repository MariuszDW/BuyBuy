//
//  MigrationStepProtocol.swift
//  BuyBuy
//
//  Created by MDW on 21/07/2025.
//

import Foundation
import CoreData

protocol MigrationStepProtocol {
    var fromVersion: String { get }
    var toVersion: String { get }
    
    func shouldMigrate(storeURL: URL, to currentModel: NSManagedObjectModel) -> Bool
    func performMigration(storeURL: URL) throws -> URL
    
    func migrateObjects(from oldContext: NSManagedObjectContext, to newContext: NSManagedObjectContext) throws
}

extension MigrationStepProtocol {
    func performMigration(storeURL: URL) throws -> URL {
        // Load old model.
        guard let oldModelURL = Bundle.main.url(forResource: fromVersion, withExtension: "momd"),
              let oldModel = NSManagedObjectModel(contentsOf: oldModelURL) else {
            throw NSError(domain: "Migration", code: 1, userInfo: [NSLocalizedDescriptionKey: "Cannot load old model"])
        }

        let oldPSC = NSPersistentStoreCoordinator(managedObjectModel: oldModel)
        try oldPSC.addPersistentStore(ofType: NSSQLiteStoreType,
                                      configurationName: nil,
                                      at: storeURL,
                                      options: [NSReadOnlyPersistentStoreOption: true])
        let oldContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        oldContext.persistentStoreCoordinator = oldPSC

        // Load new model.
        guard let newModel = NSManagedObjectModel.mergedModel(from: nil) else {
            throw NSError(domain: "Migration", code: 2, userInfo: [NSLocalizedDescriptionKey: "Cannot load new model"])
        }

        let tempURL = storeURL.deletingLastPathComponent().appendingPathComponent("Temp" + storeURL.lastPathComponent)
        if FileManager.default.fileExists(atPath: tempURL.path) {
            try FileManager.default.removeItem(at: tempURL)
        }

        let newPSC = NSPersistentStoreCoordinator(managedObjectModel: newModel)
        try newPSC.addPersistentStore(ofType: NSSQLiteStoreType,
                                      configurationName: nil,
                                      at: tempURL,
                                      options: nil)
        let newContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        newContext.persistentStoreCoordinator = newPSC

        // Perform object-level migration.
        try migrateObjects(from: oldContext, to: newContext)

        // Save and replace store.
        try newContext.save()
        try FileManager.default.removeItem(at: storeURL)
        try FileManager.default.moveItem(at: tempURL, to: storeURL)

        return storeURL
    }

    func migrateObjects(from oldContext: NSManagedObjectContext, to newContext: NSManagedObjectContext) throws {
        throw NSError(domain: "Migration", code: 3, userInfo: [NSLocalizedDescriptionKey: "migrateObjects(...) not implemented"])
    }
}
