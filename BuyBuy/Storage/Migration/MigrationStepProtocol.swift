//
//  MigrationStepProtocol.swift
//  BuyBuy
//
//  Created by MDW on 21/07/2025.
//

import Foundation
import CoreData

protocol MigrationStepProtocol {
    var fromVersion: String { get }
    var toVersion: String { get }
    
    func shouldMigrate(storeURL: URL, to currentModel: NSManagedObjectModel) -> Bool
    func performMigration(storeURL: URL) throws -> URL
}
