//
//  InMemoryShoppingListStore.swift
//  BuyBuy
//
//  Created by MDW on 16/05/2025.
//

import Foundation

// TODO: temporary class

final class InMemoryShoppingListStore {
    private(set) var lists: [ShoppingList]

    init(initialLists: [ShoppingList] = []) {
        self.lists = initialLists
    }

    func allLists() -> [ShoppingList] {
        return lists
    }

    func fetchList(with id: UUID) -> ShoppingList? {
        return lists.first { $0.id == id }
    }

    func updateList(_ updatedList: ShoppingList) {
        if let index = lists.firstIndex(where: { $0.id == updatedList.id }) {
            lists[index] = updatedList
        }
    }

    func addList(_ newList: ShoppingList) {
        lists.append(newList)
    }

    func removeList(id: UUID) {
        lists.removeAll { $0.id == id }
    }

    // MARK: - Item management

    func addItem(_ item: ShoppingItem, toListWith listID: UUID) {
        guard var list = fetchList(with: listID) else { return }
        list.items.append(item)
        updateList(list)
    }

    func updateItem(_ item: ShoppingItem, inListWith listID: UUID) {
        guard var list = fetchList(with: listID) else { return }
        if let index = list.items.firstIndex(where: { $0.id == item.id }) {
            list.items[index] = item
            updateList(list)
        }
    }

    func removeItem(with id: UUID, fromListWith listID: UUID) {
        guard var list = fetchList(with: listID) else { return }
        list.items.removeAll { $0.id == id }
        updateList(list)
    }
}
