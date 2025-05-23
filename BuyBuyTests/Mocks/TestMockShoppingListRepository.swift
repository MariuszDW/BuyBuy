//
//  MockShoppingListRepository.swift
//  BuyBuyTests
//
//  Created by MDW on 15/05/2025.
//

import Foundation
@testable import BuyBuy

final class TestMockShoppingListsRepository: ShoppingListsRepositoryProtocol, @unchecked Sendable {
    var addItemHandler: ((BuyBuy.ShoppingItem) -> Void)?
    var fetchListHandler: ((UUID) -> Void)?
    
    func deleteItem(with id: UUID) async throws {
        // TODO: implement...
    }
    
    func deleteItems(with ids: [UUID]) async throws {
        // TODO: implement...
    }
    
    func cleanOrphanedItems() async throws {
        // TODO: implement...
    }
    
    func fetchAllLists() async throws -> [BuyBuy.ShoppingList] {
        // TODO: implement...
        return []
    }
    
    func fetchList(with id: UUID) async throws -> BuyBuy.ShoppingList? {
        fetchListHandler?(id)
        return nil
    }
    
    func deleteLists(with ids: [UUID]) async throws {
        // TODO: implement...
    }
    
    func fetchItems(for listID: UUID) async throws -> [BuyBuy.ShoppingItem] {
        // TODO: implement...
        return []
    }
    
    func addItem(_ item: BuyBuy.ShoppingItem) {
        addItemHandler?(item)
    }
    
    func updateItem(_ item: BuyBuy.ShoppingItem) {
        // TODO: implement...
    }
    func getAllLists() -> [BuyBuy.ShoppingList] {
        // TODO: implement...
        return []
    }
    
    func addOrUpdateList(_ list: ShoppingList) {
        // TODO: implement...
    }
    
    func deleteList(with id: UUID) {
        // TODO: implement...
    }
    
    func getList(with id: UUID) -> BuyBuy.ShoppingList? {
        // TODO: implement...
        return nil
    }
    
    func getItems(forListID listID: UUID) -> [BuyBuy.ShoppingItem] {
        // TODO: implement...
        return []
    }
}
