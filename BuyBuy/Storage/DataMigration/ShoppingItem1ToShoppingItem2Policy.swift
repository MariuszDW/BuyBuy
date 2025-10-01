//
//  ShoppingItemMigrationPolicy.swift
//  BuyBuy
//
//  Created by MDW on 20/08/2025.
//

import Foundation
import CoreData

public class ShoppingItem1ToShoppingItem2Policy: NSEntityMigrationPolicy {
    override public func createDestinationInstances(forSource sInstance: NSManagedObject,
                                                    in mapping: NSEntityMapping,
                                                    manager: NSMigrationManager) throws {
        AppLogger.general.debug("ShoppingItem1ToShoppingItem2Policy - start")
        try super.createDestinationInstances(forSource: sInstance,
                                             in: mapping,
                                             manager: manager)

        guard let dInstance = manager.destinationInstances(forEntityMappingName: mapping.name,
                                                           sourceInstances: [sInstance]).first else {
            AppLogger.general.debug("ShoppingItemMigrationPolicy: must return destination instance")
            return
        }
        
        dInstance.setValue(NSSet(), forKey: "images")
        dInstance.setValue(NSSet(), forKey: "thumbnails")
        dInstance.setValue(Date.now, forKey: "updatedAt")
        
        AppLogger.general.debug("ShoppingItem1ToShoppingItem2Policy - end")
    }
}
