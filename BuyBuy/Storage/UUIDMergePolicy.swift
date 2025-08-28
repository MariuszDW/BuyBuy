//
//  UUIDMergePolicy.swift
//  BuyBuy
//
//  Created by MDW on 21/08/2025.
//

import CoreData

final class UUIDMergePolicy: NSMergePolicy {
    init() {
        super.init(merge: .mergeByPropertyObjectTrumpMergePolicyType)
    }

    override func resolve(optimisticLockingConflicts list: [NSMergeConflict]) throws {
        for conflict in list {
            let conflictedObject = conflict.sourceObject
            guard
                let entityName = conflictedObject.entity.name,
                let context = conflictedObject.managedObjectContext
            else { continue }

            if let id = conflictedObject.value(forKey: "id") as? UUID {
                let fetch = NSFetchRequest<NSManagedObject>(entityName: entityName)
                fetch.predicate = NSPredicate(format: "id == %@", id as CVarArg)

                let results = try context.fetch(fetch)

                if results.count > 1 {
                    for duplicate in results.dropFirst() {
                        context.delete(duplicate)
                    }
                    print("Deduplicated \(entityName) with id \(id)")
                }
            }
        }

        try super.resolve(optimisticLockingConflicts: list)
    }
}
