//
//  MockShoppingListRepository.swift
//  BuyBuyTests
//
//  Created by MDW on 15/05/2025.
//

import Foundation
@testable import BuyBuy

final class TestMockShoppingListsRepository: ShoppingListsRepositoryProtocol {
    func fetchAllLists() async throws -> [BuyBuy.ShoppingList] {
        // TODO: implement...
        return []
    }
    
    func fetchList(with id: UUID) async throws -> BuyBuy.ShoppingList? {
        // TODO: implement...
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
        // TODO: implement...
    }
    
    func updateItem(_ item: BuyBuy.ShoppingItem) {
        // TODO: implement...
    }
    func getAllLists() -> [BuyBuy.ShoppingList] {
        // TODO: implement...
        return []
    }
    
    func addList(_ list: BuyBuy.ShoppingList) {
        // TODO: implement...
    }
    
    func updateList(_ list: BuyBuy.ShoppingList) {
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
    
    func deleteItem(_ item: BuyBuy.ShoppingItem) {
        // TODO: implement...
    }
}
