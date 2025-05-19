//
//  ShoppingListRepository.swift
//  BuyBuy
//
//  Created by MDW on 15/05/2025.
//

import Foundation

class ShoppingListRepository: ShoppingListRepositoryProtocol {
    private let store: InMemoryShoppingListStore // TODO: temporary solution; in a future it will be replaced by a CoreData solution
    private let listID: UUID

    init(listID: UUID, store: InMemoryShoppingListStore) {
        self.listID = listID
        self.store = store
    }

    func getItems() -> ShoppingList? {
        return store.fetchList(with: listID)
    }

    func addItem(_ item: ShoppingItem) {
        store.addItem(item, toListWith: listID)
    }

    func updateItem(_ item: ShoppingItem) {
        store.updateItem(item, inListWith: listID)
    }

    func removeItem(with id: UUID) {
        store.removeItem(with: id, fromListWith: listID)
    }
}
