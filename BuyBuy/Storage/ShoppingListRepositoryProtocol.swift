//
//  ShoppingListRepositoryProtocol.swift
//  BuyBuy
//
//  Created by MDW on 20/05/2025.
//

import Foundation

protocol ShoppingListsRepositoryProtocol: Sendable {
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
    
    func fetchAllImageIDs() async throws -> Set<String>
}
