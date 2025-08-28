//
//  Deduplicator.swift
//  BuyBuy
//
//  Created by MDW on 21/08/2025.
//

import CoreData

final class Deduplicator {
    static func deduplicateAndMergeAllEntities(in context: NSManagedObjectContext) throws {
        let entityNames = [
            "ShoppingListEntity",
            "ShoppingItemEntity",
            "LoyaltyCardEntity",
            "BBImageEntity",
            "BBThumbnailEntity"
        ]
        
        for entityName in entityNames {
            try deduplicateAndMerge(entityName: entityName, in: context)
        }
        
        if context.hasChanges {
            try context.save()
        }
    }
    
    private static func deduplicateAndMerge(entityName: String, in context: NSManagedObjectContext) throws {
        let fetch = NSFetchRequest<NSManagedObject>(entityName: entityName)
        let objects = try context.fetch(fetch)
        
        var uniqueObjects = [UUID: NSManagedObject]()
        var duplicates = [(NSManagedObject, NSManagedObject)]() // (duplicate, keeper)
        
        for obj in objects {
            guard let id = obj.value(forKey: "id") as? UUID else { continue }
            
            if let keeper = uniqueObjects[id] {
                duplicates.append((obj, keeper))
            } else {
                uniqueObjects[id] = obj
            }
        }
        
        for (duplicate, keeper) in duplicates {
            mergeFields(from: duplicate, into: keeper)
            context.delete(duplicate)
            print("Deduplicated and merged \(entityName) with id \(keeper.value(forKey: "id")!)")
        }
    }
    
    private static func mergeFields(from source: NSManagedObject, into target: NSManagedObject) {
        let sourceUpdatedAt = updatedAt(for: source)
        let targetUpdatedAt = updatedAt(for: target)

        for (attribute, attrDesc) in target.entity.attributesByName {
            if attribute == "id" || attribute == "updatedAt" { continue }

            let sourceValue = source.value(forKey: attribute)
            let targetValue = target.value(forKey: attribute)

            // case 1 - Source has value, target is nil → copy source to target
            if sourceValue != nil && targetValue == nil {
                target.setValue(sourceValue, forKey: attribute)
                continue
            }

            // case 2 - Both have values and are different → use updatedAt to decide
            if let s = sourceValue, let t = targetValue, !isEqual(s, t, attributeType: attrDesc.attributeType) {
                if sourceUpdatedAt > targetUpdatedAt {
                    target.setValue(s, forKey: attribute)
                }
                continue
            }

            // case 3 - Target has value, source is nil → leave target as is
            if sourceValue == nil && targetValue != nil {
                continue
            }

            // case 4 - Both nil → do nothing
        }
    }

    private static func updatedAt(for object: NSManagedObject) -> Date {
        if object.entity.attributesByName.keys.contains("updatedAt"),
           let date = object.value(forKey: "updatedAt") as? Date {
            return date
        }
        return .distantPast
    }

    private static func isEqual(_ a: Any?, _ b: Any?, attributeType: NSAttributeType) -> Bool {
        switch attributeType {
        case .stringAttributeType:
            return (a as? String) == (b as? String)
        case .integer16AttributeType, .integer32AttributeType, .integer64AttributeType:
            return (a as? NSNumber)?.int64Value == (b as? NSNumber)?.int64Value
        case .decimalAttributeType, .doubleAttributeType, .floatAttributeType:
            return (a as? NSNumber)?.doubleValue == (b as? NSNumber)?.doubleValue
        case .booleanAttributeType:
            return (a as? Bool) == (b as? Bool)
        case .dateAttributeType:
            return (a as? Date) == (b as? Date)
        case .binaryDataAttributeType:
            return (a as? Data) == (b as? Data)
        case .UUIDAttributeType:
            return (a as? UUID) == (b as? UUID)
        case .transformableAttributeType:
            return (a as? NSObject) == (b as? NSObject)
        default:
            return false
        }
    }
}
