//
//  CoreDataStackProtocol.swift
//  BuyBuy
//
//  Created by MDW on 25/06/2025.
//

import Foundation
import CoreData

protocol CoreDataStackProtocol: Sendable {
    var saveQueue: SaveQueue { get }
    var viewContext: NSManagedObjectContext { get }
    func newBackgroundContext() -> NSManagedObjectContext
}
