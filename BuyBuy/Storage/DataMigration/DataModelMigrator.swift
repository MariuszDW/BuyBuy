//
//  DataModelMigrator.swift
//  BuyBuy
//
//  Created by MDW on 20/08/2025.
//

import Foundation
import CoreData

class DataModelMigrator {
    private let storeURL: URL
    private let modelName: String
    
    private let heavyMigrationSourceModels = ["Model"]
    private let allVersions = ["Model", "Model_v2"]
    
    init(storeURL: URL, modelName: String = AppConstants.coreDataModelName) {
        self.storeURL = storeURL
        self.modelName = modelName
    }
    
    func migrateIfNeeded() throws {
        forceWALCheckpointingForStore(at: storeURL)
        
        let metadata = try NSPersistentStoreCoordinator.metadataForPersistentStore(
            ofType: NSSQLiteStoreType,
            at: storeURL
        )
        
        guard !allVersions.isEmpty else { return }
        
        guard let destinationModel = loadModel(name: allVersions.last!),
              !destinationModel.isConfiguration(withName: nil, compatibleWithStoreMetadata: metadata) else {
            print("Store already up-to-date")
            return
        }
        
        let sourceVersionName = detectSourceVersion(metadata: metadata)
        print("Detected source version: \(sourceVersionName)")
        
        guard let sourceIndex = allVersions.firstIndex(of: sourceVersionName),
              let destinationIndex = allVersions.firstIndex(of: allVersions.last!) else {
            throw NSError(domain: "DataModelMigrator", code: 1,
                          userInfo: [NSLocalizedDescriptionKey: "Cannot determine migration path"])
        }
        
        if sourceIndex == destinationIndex { return }
        
        let currentURL = storeURL
        for idx in sourceIndex..<destinationIndex {
            let fromName = allVersions[idx]
            let toName = allVersions[idx + 1]
            
            guard let sourceModel = loadModel(name: fromName),
                  let destinationModel = loadModel(name: toName) else {
                throw NSError(domain: "DataModelMigrator", code: 2,
                              userInfo: [NSLocalizedDescriptionKey: "Cannot load models for migration"])
            }
            
            print("Migrating \(fromName) → \(toName)")
            
            if heavyMigrationSourceModels.contains(fromName) {
                guard let mappingModel = NSMappingModel(from: [Bundle.main],
                                                        forSourceModel: sourceModel,
                                                        destinationModel: destinationModel) else {
                    throw NSError(domain: "DataModelMigrator", code: 3,
                                  userInfo: [NSLocalizedDescriptionKey: "Custom mapping model required for heavy migration"])
                }
                
                try performHeavyMigration(sourceModel: sourceModel,
                                          destinationModel: destinationModel,
                                          mappingModel: mappingModel,
                                          storeURL: currentURL)
            } else {
                if let mappingModel = NSMappingModel(from: [Bundle.main],
                                                     forSourceModel: sourceModel,
                                                     destinationModel: destinationModel) {
                    try performHeavyMigration(sourceModel: sourceModel,
                                              destinationModel: destinationModel,
                                              mappingModel: mappingModel,
                                              storeURL: currentURL)
                } else {
                    try performLightMigration(destinationModel: destinationModel, storeURL: currentURL)
                }
            }
        }
        
        print("Migration completed for store: \(storeURL.lastPathComponent)")
    }
    
    // MARK: - WAL Checkpoint
    
    private func forceWALCheckpointingForStore(at: URL) {
        guard FileManager.default.fileExists(atPath: storeURL.path) else {
            print("ℹ️ Store file not found, skipping checkpointing for \(storeURL.lastPathComponent)")
            return
        }
        
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: NSManagedObjectModel())
        let options: [AnyHashable: Any] = [
            NSSQLitePragmasOption: ["journal_mode": "DELETE"]
        ]
        
        do {
            let store = try coordinator.addPersistentStore(
                ofType: NSSQLiteStoreType,
                configurationName: nil,
                at: storeURL,
                options: options
            )
            try coordinator.remove(store)
            print("WAL checkpointing completed for \(storeURL.lastPathComponent)")
        } catch let error as NSError {
            if error.domain == NSCocoaErrorDomain && error.code == NSPersistentStoreIncompatibleVersionHashError {
                print("WAL checkpointing skipped for \(storeURL.lastPathComponent) – model mismatch (expected if migration is needed).")
            } else {
                print("WAL checkpointing failed for \(storeURL.lastPathComponent): \(error)")
            }
        }
    }
    
    // MARK: - Helpers
    
    private func loadModel(name: String) -> NSManagedObjectModel? {
        let momd = "\(modelName).momd"
        if let omoURL = Bundle.main.url(forResource: name, withExtension: "omo", subdirectory: momd),
           let model = NSManagedObjectModel(contentsOf: omoURL) {
            return model
        } else if let momURL = Bundle.main.url(forResource: name, withExtension: "mom", subdirectory: momd),
                  let model = NSManagedObjectModel(contentsOf: momURL) {
            return model
        }
        return nil
    }
    
    private func detectSourceVersion(metadata: [String: Any]) -> String {
        let momd = "\(modelName).momd"
        if let urls = Bundle.main.urls(forResourcesWithExtension: "mom", subdirectory: momd) {
            for url in urls {
                if let model = NSManagedObjectModel(contentsOf: url),
                   model.isConfiguration(withName: nil, compatibleWithStoreMetadata: metadata) {
                    return url.deletingPathExtension().lastPathComponent
                }
            }
        }
        return "unknown"
    }
    
    private func performHeavyMigration(sourceModel: NSManagedObjectModel,
                                       destinationModel: NSManagedObjectModel,
                                       mappingModel: NSMappingModel,
                                       storeURL: URL) throws {
        let tmpURL = storeURL.deletingPathExtension().appendingPathExtension("tmp.sqlite")
        try? FileManager.default.removeItem(at: tmpURL)
        
        let options: [String: Any] = [
            NSMigratePersistentStoresAutomaticallyOption: false,
            NSInferMappingModelAutomaticallyOption: false
        ]
        
        let manager = NSMigrationManager(sourceModel: sourceModel, destinationModel: destinationModel)
        try manager.migrateStore(from: storeURL,
                                 sourceType: NSSQLiteStoreType,
                                 options: options,
                                 with: mappingModel,
                                 toDestinationURL: tmpURL,
                                 destinationType: NSSQLiteStoreType,
                                 destinationOptions: options)
        
        try FileManager.default.removeItem(at: storeURL)
        try FileManager.default.moveItem(at: tmpURL, to: storeURL)
    }
    
    private func performLightMigration(destinationModel: NSManagedObjectModel, storeURL: URL) throws {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: destinationModel)
        let options: [String: Any] = [
            NSMigratePersistentStoresAutomaticallyOption: true,
            NSInferMappingModelAutomaticallyOption: true
        ]
        try coordinator.addPersistentStore(ofType: NSSQLiteStoreType,
                                           configurationName: nil,
                                           at: storeURL,
                                           options: options)
    }
}
