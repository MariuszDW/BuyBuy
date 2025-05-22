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
    func addList(_ list: ShoppingList) async throws
    func updateList(_ list: ShoppingList) async throws
    func deleteList(with id: UUID) async throws
    func deleteLists(with ids: [UUID]) async throws

    // Items
    func fetchItems(for listID: UUID) async throws -> [ShoppingItem]
    func addItem(_ item: ShoppingItem) async throws
    func updateItem(_ item: ShoppingItem) async throws
    func deleteItem(_ item: ShoppingItem) async throws
    func cleanOrphanedItems() async throws
}
