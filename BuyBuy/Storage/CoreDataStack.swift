//
//  CoreDataStack.swift
//  BuyBuy
//
//  Created by MDW on 21/05/2025.
//

import Foundation
import CoreData
import CloudKit

final class CoreDataStack: @unchecked Sendable, CoreDataStackProtocol {
    let container: NSPersistentContainer
    
    init(useCloudSync: Bool) {
        let modelName = AppConstants.coreDataModelName
        
        if useCloudSync {
            container = NSPersistentCloudKitContainer(name: modelName)
        } else {
            container = NSPersistentContainer(name: modelName)
        }
        
        guard let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: AppConstants.appGroupID) else {
            fatalError("Can not find App Group directory")
        }
        
        let storeFileName = useCloudSync ? AppConstants.cloudStoreFileName : AppConstants.localStoreFileName
        try? FileManager.default.createDirectory(at: containerURL, withIntermediateDirectories: true)
        let storeURL = containerURL.appendingPathComponent(storeFileName)
        
        if let description = container.persistentStoreDescriptions.first {
            description.url = storeURL
            
            if useCloudSync {
                description.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: AppConstants.iCloudContainerID)
                description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
                description.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
            } else {
                description.cloudKitContainerOptions = nil
            }
        }
        
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Core Data failed to load: \(error.localizedDescription)")
            } else {
                print("Core Data store loaded: \(description.url?.absoluteString ?? "unknown URL")")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
    }
    
    var viewContext: NSManagedObjectContext {
        container.viewContext
    }
    
    func newBackgroundContext() -> NSManagedObjectContext {
        let context = container.newBackgroundContext()
        context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        context.transactionAuthor = "SaveQueue"
        return context
    }
}
