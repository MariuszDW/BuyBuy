//
//  DataModelMigrator.swift
//  BuyBuy
//
//  Created by MDW on 21/07/2025.
//

import Foundation
import CoreData

final class DataModelMigrator {
    private let storeURL: URL
    private let currentModel: NSManagedObjectModel
    private var migrations: [MigrationStepProtocol] = []
    
    init(storeURL: URL) {
        self.storeURL = storeURL
        
        guard let model = NSManagedObjectModel.mergedModel(from: nil) else {
            fatalError("Can't load current NSManagedObjectModel")
        }
        self.currentModel = model
        
        registerMigrations()
    }
    
    private func registerMigrations() {
        // register(ExampleMigration_v1_to_v2())
        register(DataMigration_v1_to_v2())
    }
    
    func register(_ migration: MigrationStepProtocol) {
        migrations.append(migration)
    }
    
    func migrateIfNeeded() throws {
        guard FileManager.default.fileExists(atPath: storeURL.path) else {
            print("Store file does not exist at \(storeURL.path), no migration needed.")
            return
        }
        
        var currentStoreURL = storeURL
        
        for migration in migrations {
            if migration.shouldMigrate(storeURL: currentStoreURL, to: currentModel) {
                print("Migrating from \(migration.fromVersion) to \(migration.toVersion)")
                currentStoreURL = try migration.performMigration(storeURL: currentStoreURL)
            }
        }
        
        let finalMetadata = Self.metadataForStore(at: currentStoreURL)
        if currentModel.isConfiguration(withName: nil, compatibleWithStoreMetadata: finalMetadata) {
            print("Final model is compatible, migration completed.")
        } else {
            print("Warning: Migration may have failed, store is still incompatible.")
        }
    }
    
    static func metadataForStore(at url: URL) -> [String: Any] {
        guard let metadata = try? NSPersistentStoreCoordinator.metadataForPersistentStore(ofType: NSSQLiteStoreType, at: url) else {
            return [:]
        }
        return metadata
    }
}
