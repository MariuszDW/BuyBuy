//
//  LoyaltyCardMigrationPolicy.swift
//  BuyBuy
//
//  Created by MDW on 20/08/2025.
//

import Foundation
import CoreData

public class LoyaltyCard1ToLoyaltyCard2Policy: NSEntityMigrationPolicy {
    override public func createDestinationInstances(forSource sInstance: NSManagedObject,
                                                    in mapping: NSEntityMapping,
                                                    manager: NSMigrationManager) throws {
        
        AppLogger.general.debug("LoyaltyCard1ToLoyaltyCard2Policy - start")
        try super.createDestinationInstances(forSource: sInstance,
                                             in: mapping,
                                             manager: manager)

        guard let dInstance = manager.destinationInstances(forEntityMappingName: mapping.name,
                                                           sourceInstances: [sInstance]).first else {
            AppLogger.general.debug("LoyaltyCardMigrationPolicy: must return destination instance")
            return
        }
        
        dInstance.setValue(nil, forKey: "image")
        dInstance.setValue(nil, forKey: "thumbnail")
        dInstance.setValue(Date.now, forKey: "updatedAt")
        
        AppLogger.general.debug("LoyaltyCard1ToLoyaltyCard2Policy - end")
    }
}
