//
//  NSManagedObjectContext+Extensions.swift
//  BuyBuy
//
//  Created by MDW on 28/07/2025.
//

import CoreData

extension NSManagedObjectContext {
    var isCloud: Bool {
        get {
            return (userInfo[CoreDataStack.isCloudKey] as? Bool) ?? false
        }
        set {
            userInfo[CoreDataStack.isCloudKey] = newValue
        }
    }
}
