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

    func fetchAllLists() -> [ShoppingList] {
        return store.allLists()
    }

    func addList(_ list: ShoppingList) {
        store.addList(list)
    }
    
    func updateList(_ updatedList: ShoppingList) {
        store.updateList(updatedList)
    }
    
    func deleteList(with id: UUID) {
        store.removeList(id: id)
    }
}
