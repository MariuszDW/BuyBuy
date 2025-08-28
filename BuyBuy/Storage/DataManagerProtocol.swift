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
    func fetchAllLists() async throws -> [ShoppingList]
    func fetchList(with id: UUID) async throws -> ShoppingList?
    func addOrUpdateList(_ list: ShoppingList) async throws
    func deleteList(with id: UUID, moveItemsToDeleted: Bool) async throws
    func deleteLists(with ids: [UUID], moveItemsToDeleted: Bool) async throws
    func deleteAllLists() async throws

    // Shopping items
    func fetchAllItems() async throws -> [ShoppingItem]
    func fetchItemsOfList(with listID: UUID) async throws -> [ShoppingItem]
    func fetchItem(with id: UUID) async throws -> ShoppingItem?
    func fetchDeletedItems() async throws -> [ShoppingItem]
    func addOrUpdateItem(_ item: ShoppingItem) async throws
    func moveItemToDeleted(with id: UUID) async throws
    func moveItemsToDeleted(with ids: [UUID]) async throws
    func restoreItem(with id: UUID, toList listID: UUID) async throws
    func deleteOldTrashedItems(olderThan days: Int) async throws
    func deleteItem(with id: UUID) async throws
    func deleteItems(with ids: [UUID]) async throws
    func deleteAllItems() async throws
    func cleanOrphanedItems() async throws
    func fetchAllItemImageIDs() async throws -> Set<String>
    func fetchItemsWithMissingImages() async throws -> [ShoppingItem]
    
    // Loyalty cards
    func fetchLoyaltyCards() async throws -> [LoyaltyCard]
    func fetchLoyaltyCard(with id: UUID) async throws -> LoyaltyCard?
    func addOrUpdateLoyaltyCard(_ card: LoyaltyCard) async throws
    func deleteLoyaltyCard(with id: UUID) async throws
    func deleteAllLoyaltyCards() async throws
    func fetchAllLoyaltyCardImageIDs() async throws -> Set<String>
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
    
    // Debug
#if DEBUG
//    func printEnvironmentPaths() async
#endif
}
