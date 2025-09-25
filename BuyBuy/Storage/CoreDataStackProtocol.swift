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
    var isCloud: Bool { get }
    var privateCloudPersistentStore: NSPersistentStore? { get }
    var sharedCloudPersistentStore: NSPersistentStore? { get }
    var devicePersistentStore: NSPersistentStore? { get }
    var container: NSPersistentContainer { get }
    func fetchRemoteChanges() async
    var viewContext: NSManagedObjectContext { get }
    func newBackgroundContext() -> NSManagedObjectContext
    func teardown() async
}
