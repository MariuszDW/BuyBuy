//
//  DataRepositoryProtocol.swift
//  BuyBuy
//
//  Created by MDW on 20/05/2025.
//

import Foundation

protocol DataRepositoryProtocol: Sendable {
    // Lists
    func fetchAllLists() async throws -> [ShoppingList]
    func fetchList(with id: UUID) async throws -> ShoppingList?
    func addOrUpdateList(_ list: ShoppingList) async throws
    func deleteList(with id: UUID) async throws
    func deleteLists(with ids: [UUID]) async throws

    // Items
    func fetchAllItems() async throws -> [ShoppingItem]
    func fetchItemsOfList(with listID: UUID) async throws -> [ShoppingItem]
    func fetchItem(with id: UUID) async throws -> ShoppingItem?
    func fetchItems(with ids: [UUID]) async throws -> [ShoppingItem]
    func addOrUpdateItem(_ item: ShoppingItem) async throws
    func deleteItem(with id: UUID) async throws
    func deleteItems(with ids: [UUID]) async throws
    func cleanOrphanedItems() async throws
    
    // Item images
    func fetchAllItemImageIDs() async throws -> Set<String>
    
    // Loyalty Cards
    func fetchAllLoyaltyCards() async throws -> [LoyaltyCard]
    func fetchLoyaltyCard(with id: UUID) async throws -> LoyaltyCard?
    func addOrUpdateLoyaltyCard(_ card: LoyaltyCard) async throws
    func deleteLoyaltyCard(with id: UUID) async throws
    
    // Loyalty images
    func fetchAllLoyaltyCardImageIDs() async throws -> Set<String>
}
