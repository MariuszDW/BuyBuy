//
//  DataRepositoryProtocol.swift
//  BuyBuy
//
//  Created by MDW on 20/05/2025.
//

import Foundation

protocol DataRepositoryProtocol: Sendable {
    // Shopping lists
    func fetchAllLists() async throws -> [ShoppingList]
    func fetchList(with id: UUID) async throws -> ShoppingList?
    func addOrUpdateList(_ list: ShoppingList) async throws
    func deleteList(with id: UUID) async throws
    func deleteLists(with ids: [UUID]) async throws
    func deleteAllLists() async throws

    // Shopping items
    func fetchAllItems() async throws -> [ShoppingItem]
    func fetchItemsOfList(with listID: UUID) async throws -> [ShoppingItem]
    func fetchItem(with id: UUID) async throws -> ShoppingItem?
    func fetchItems(with ids: [UUID]) async throws -> [ShoppingItem]
    func fetchDeletedItems() async throws -> [ShoppingItem]
    func fetchMaxOrderOfItems(inList listID: UUID) async throws -> Int
    func addOrUpdateItem(_ item: ShoppingItem) async throws
    func deleteItem(with id: UUID) async throws
    func deleteItems(with ids: [UUID]) async throws
    func deleteAllItems() async throws
    func cleanOrphanedItems() async throws
    func fetchItemsWithMissingImages() async throws -> [ShoppingItem]
    
    // Loyalty cards
    func fetchLoyaltyCards() async throws -> [LoyaltyCard]
    func fetchLoyaltyCard(with id: UUID) async throws -> LoyaltyCard?
    func addOrUpdateLoyaltyCard(_ card: LoyaltyCard) async throws
    func deleteLoyaltyCard(with id: UUID) async throws
    func deleteAllLoyaltyCards() async throws
    func fetchLoyaltyCardsWithMissingImages() async throws -> [LoyaltyCard]
    
    // Images
    func fetchImageData(id: String) async throws -> Data?
    func fetchThumbnailData(id: String) async throws -> Data?
    func fetchAllItemImageIDs() async throws -> Set<String>
    func fetchAllLoyaltyCardImageIDs() async throws -> Set<String>
    
    // CloudKit
    func fetchRemoteChangesFromCloudKit()
}
