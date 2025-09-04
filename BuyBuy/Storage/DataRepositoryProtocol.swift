//
//  DataRepositoryProtocol.swift
//  BuyBuy
//
//  Created by MDW on 20/05/2025.
//

import Foundation

protocol DataRepositoryProtocol: Sendable {
    // Shopping lists
    func fetchShoppingLists() async throws -> [ShoppingList]
    func fetchShoppingList(with id: UUID) async throws -> ShoppingList?
    func addOrUpdateShoppingList(_ list: ShoppingList) async throws
    func deleteShoppingList(with id: UUID) async throws
    func deleteShoppingLists(with ids: [UUID]) async throws
    func deleteShoppingLists() async throws

    // Shopping items
    func fetchShoppingItems() async throws -> [ShoppingItem]
    func fetchShoppingItemsOfList(with listID: UUID) async throws -> [ShoppingItem]
    func fetchShoppingItem(with id: UUID) async throws -> ShoppingItem?
    func fetchShoppingItems(with ids: [UUID]) async throws -> [ShoppingItem]
    func fetchDeletedShoppingItems() async throws -> [ShoppingItem]
    func fetchMaxOrderOfShoppingItems(ofList listID: UUID) async throws -> Int
    func fetchMaxOrderOfShoppingItems(ofList listID: UUID, status: ShoppingItemStatus) async throws -> Int
    func addOrUpdateShoppingItem(_ item: ShoppingItem) async throws
    func deleteShoppingItem(with id: UUID) async throws
    func deleteShoppingItems(with ids: [UUID]) async throws
    func deleteShoppingItems() async throws
    func cleanOrphanedShoppingItems() async throws
    func fetchShoppingItemsWithMissingImages() async throws -> [ShoppingItem]
    
    // Loyalty cards
    func fetchLoyaltyCards() async throws -> [LoyaltyCard]
    func fetchLoyaltyCard(with id: UUID) async throws -> LoyaltyCard?
    func addOrUpdateLoyaltyCard(_ card: LoyaltyCard) async throws
    func deleteLoyaltyCard(with id: UUID) async throws
    func deleteLoyaltyCards() async throws
    func fetchLoyaltyCardsWithMissingImages() async throws -> [LoyaltyCard]
    
    // Images
    func fetchImageData(id: String) async throws -> Data?
    func fetchThumbnailData(id: String) async throws -> Data?
    func fetchShoppingItemImageIDs() async throws -> Set<String>
    func fetchLoyaltyCardImageIDs() async throws -> Set<String>
    
    // CloudKit
    func fetchRemoteChangesFromCloudKit()
}
