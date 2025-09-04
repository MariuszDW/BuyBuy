//
//  DataManagerProtocol.swift
//  BuyBuy
//
//  Created by MDW on 30/05/2025.
//

import Foundation
import SwiftUI

@MainActor
protocol DataManagerProtocol {
    var cloud: Bool { get }
    var coreDataStack: CoreDataStackProtocol { get }
    var storageManager: StorageManagerProtocol { get }
    
    func setup(useCloud: Bool) async
    
    // Shopping lists
    func fetchShoppingLists() async throws -> [ShoppingList]
    func fetchShoppingList(with id: UUID) async throws -> ShoppingList?
    func addOrUpdateShoppingList(_ list: ShoppingList) async throws
    func deleteShoppingList(with id: UUID, moveItemsToDeleted: Bool) async throws
    func deleteShoppingLists(with ids: [UUID], moveItemsToDeleted: Bool) async throws
    func deleteShoppingLists() async throws

    // Shopping items
    func fetchShoppingItems() async throws -> [ShoppingItem]
    func fetchShoppingItemsOfList(with listID: UUID) async throws -> [ShoppingItem]
    func fetchShoppingItem(with id: UUID) async throws -> ShoppingItem?
    func fetchDeletedShoppingItems() async throws -> [ShoppingItem]
    func addOrUpdateShoppingItem(_ item: ShoppingItem) async throws
    func moveShoppingItemToDeleted(with id: UUID) async throws
    func moveShoppingItemsToDeleted(with ids: [UUID]) async throws
    func restoreShoppingItem(with id: UUID, toList listID: UUID) async throws
    func deleteOldTrashedShoppingItems(olderThan days: Int) async throws
    func deleteShoppingItem(with id: UUID) async throws
    func deleteShoppingItems(with ids: [UUID]) async throws
    func deleteShoppingItems() async throws
    func cleanOrphanedShoppingItems() async throws
    func fetchShoppingItemImageIDs() async throws -> Set<String>
    func fetchShoppingItemsWithMissingImages() async throws -> [ShoppingItem]
    func fetchMaxOrderOfShoppingItems(ofList listID: UUID) async throws -> Int
    func fetchMaxOrderOfShoppingItems(ofList listID: UUID, status: ShoppingItemStatus) async throws -> Int
    
    // Loyalty cards
    func fetchLoyaltyCards() async throws -> [LoyaltyCard]
    func fetchLoyaltyCard(with id: UUID) async throws -> LoyaltyCard?
    func addOrUpdateLoyaltyCard(_ card: LoyaltyCard) async throws
    func deleteLoyaltyCard(with id: UUID) async throws
    func deleteLoyaltyCards() async throws
    func fetchLoyaltyCardImageIDs() async throws -> Set<String>
    func fetchLoyaltyCardsWithMissingImages() async throws -> [LoyaltyCard]
    
    // Images
    func saveImageToTemporaryDir(_ image: UIImage, baseFileName: String) async throws
    func loadImage(with baseFileName: String) async throws -> UIImage?
    func loadThumbnail(with baseFileName: String) async throws -> UIImage?
    func cleanImageCache() async
    func cleanTemporaryImages() async
    
    // Files
    func saveFile(fileName: String, from base: StorageLocation, subfolders: [String]?, data: Data)
    func readFile(named fileName: String, from base: StorageLocation, subfolders: [String]?) -> Data?
    func deleteFile(named fileName: String, in base: StorageLocation, subfolders: [String]?)
    func listFiles(in base: StorageLocation, subfolders: [String]?) /*async throws*/ -> [String]
    
    // Refresh cloud data
    func refreshAllCloudData() async
    
    // BUYBUY_DEV
#if BUYBUY_DEV
//    func printEnvironmentPaths() async
#endif
}
