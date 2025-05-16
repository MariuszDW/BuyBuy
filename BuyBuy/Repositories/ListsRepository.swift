//
//  ListsRepository.swift
//  BuyBuy
//
//  Created by MDW on 15/05/2025.
//

import Foundation

final class ListsRepository: ListsRepositoryProtocol {
    private let store: InMemoryShoppingListStore

    init(store: InMemoryShoppingListStore) {
        self.store = store
    }

    func fetchAllLists() -> [ShoppingList] {
        return store.allLists()
    }

    func addList(_ list: ShoppingList) {
        store.addList(list)
    }

    func deleteList(with id: UUID) {
        store.removeList(id: id)
    }
    
    func updateList(_ updatedList: ShoppingList) {
        store.updateList(updatedList)
    }
}
