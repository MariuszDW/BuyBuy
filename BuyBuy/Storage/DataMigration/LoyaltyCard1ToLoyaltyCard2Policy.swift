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
        
        print("LoyaltyCard1ToLoyaltyCard2Policy - start")
        try super.createDestinationInstances(forSource: sInstance,
                                             in: mapping,
                                             manager: manager)

        guard let dInstance = manager.destinationInstances(forEntityMappingName: mapping.name,
                                                           sourceInstances: [sInstance]).first else {
            NSLog("LoyaltyCardMigrationPolicy: must return destination instance")
            return
        }
        
        dInstance.setValue(nil, forKey: "image")
        dInstance.setValue(nil, forKey: "thumbnail")
        dInstance.setValue(Date.now, forKey: "updatedAt")
        
        print("LoyaltyCard1ToLoyaltyCard2Policy - end")
    }
}
