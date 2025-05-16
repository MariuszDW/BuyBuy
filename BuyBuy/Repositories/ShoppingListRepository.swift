//
//  ShoppingListRepository.swift
//  BuyBuy
//
//  Created by MDW on 15/05/2025.
//

import Foundation

final class ShoppingListRepository: ShoppingListRepositoryProtocol {
    private let store: InMemoryShoppingListStore
    private let listID: UUID

    init(listID: UUID, store: InMemoryShoppingListStore) {
        self.listID = listID
        self.store = store
    }

    func fetchList() -> ShoppingList? {
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
