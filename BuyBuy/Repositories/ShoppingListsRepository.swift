//
//  ShoppingListsRepository.swift
//  BuyBuy
//
//  Created by MDW on 15/05/2025.
//

import Foundation

final class ShoppingListsRepository: ShoppingListsRepositoryProtocol {
    private let store: InMemoryShoppingListStore // TODO: The store will be replaced by a CoreData storage.
    
    init(store: InMemoryShoppingListStore) {
        self.store = store
    }
    
    // MARK: - Shopping Lists

    func getAllLists() -> [ShoppingList] {
        return store.allLists()
    }

    func addList(_ list: ShoppingList) {
        store.addList(list)
    }
    
    func updateList(_ list: ShoppingList) {
        store.updateList(list)
    }
    
    func deleteList(with id: UUID) {
        store.removeList(id: id)
    }
    
    func getList(with id: UUID) -> ShoppingList? {
        return store.getList(with: id)
    }
    
    // MARK: - Shopping Items
    
    func getItems(for listID: UUID) -> [ShoppingItem] {
        return store.getList(with: listID)?.items ?? []
    }

    func addItem(_ item: ShoppingItem) {
        store.addItem(item)
    }

    func updateItem(_ item: ShoppingItem) {
        store.updateItem(item)
    }
    
    func removeItem(_ item: ShoppingItem) {
        store.removeItem(item)
    }
}
