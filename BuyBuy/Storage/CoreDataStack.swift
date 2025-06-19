//
//  CoreDataStack.swift
//  BuyBuy
//
//  Created by MDW on 21/05/2025.
//

import Foundation
import CoreData
import CloudKit

final class CoreDataStack: @unchecked Sendable {
    let container: NSPersistentCloudKitContainer

    init(modelName: String = "Model") {
        container = NSPersistentCloudKitContainer(name: modelName)

        // CloudKit config - history and notification about changes.
        if let description = container.persistentStoreDescriptions.first {
            description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
            description.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        }

        container.loadPersistentStores { description, error in
            if let error = error {
                print("Core Data failed to load with error: \(error.localizedDescription)")
                // TODO: Handle the error?
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
        return context
    }
}
