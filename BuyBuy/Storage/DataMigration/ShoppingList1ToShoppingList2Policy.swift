//
//  ShoppingList1ToShoppingList2Policy.swift
//  BuyBuy
//
//  Created by MDW on 21/08/2025.
//

import CoreData

public class ShoppingList1ToShoppingList2Policy: NSEntityMigrationPolicy {
    override public func createDestinationInstances(forSource sInstance: NSManagedObject,
                                                    in mapping: NSEntityMapping,
                                                    manager: NSMigrationManager) throws {
        AppLogger.general.debug("ShoppingList1ToShoppingList2Policy - start")
        try super.createDestinationInstances(forSource: sInstance,
                                             in: mapping,
                                             manager: manager)

        guard let dInstance = manager.destinationInstances(forEntityMappingName: mapping.name,
                                                           sourceInstances: [sInstance]).first else {
            AppLogger.general.debug("ShoppingList1ToShoppingList2Policy: must return destination instance")
            return
        }
        
        dInstance.setValue(Date.now, forKey: "updatedAt")
        
        AppLogger.general.debug("ShoppingList1ToShoppingList2Policy - end")
    }
}
