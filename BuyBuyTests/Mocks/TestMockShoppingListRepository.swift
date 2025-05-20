//
//  MockShoppingListRepository.swift
//  BuyBuyTests
//
//  Created by MDW on 15/05/2025.
//

import Foundation
@testable import BuyBuy

final class TestMockShoppingListsRepository: ShoppingListsRepositoryProtocol {
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
    
    func getItems(for listID: UUID) -> [BuyBuy.ShoppingItem] {
        // TODO: implement...
        return []
    }
    
    func removeItem(_ item: BuyBuy.ShoppingItem) {
        // TODO: implement...
    }
    
//    var fetchListHandler: (() -> ShoppingList)?
//    var addItemHandler: ((ShoppingItem) -> Void)?
//    var updateItemHandler: ((ShoppingItem) -> Void)?
//    var removeItemHandler: ((UUID) -> Void)?
//
//    func getItems() -> ShoppingList? {
//        fetchListHandler?()
//    }
//
//    func addItem(_ item: ShoppingItem) {
//        addItemHandler?(item)
//    }
//
//    func updateItem(_ item: ShoppingItem) {
//        updateItemHandler?(item)
//    }
//
//    func removeItem(with id: UUID) {
//        removeItemHandler?(id)
//    }
}
