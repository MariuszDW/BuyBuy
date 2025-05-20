//
//  InMemoryShoppingListStore.swift
//  BuyBuy
//
//  Created by MDW on 16/05/2025.
//

import Foundation

final class InMemoryShoppingListStore { // TOOD: temporary class; it will be replaced by z CoreData solution
    private(set) var lists: [ShoppingList]

    init(initialLists: [ShoppingList] = []) {
        self.lists = initialLists.sorted(by: { $0.order < $1.order })
        for (_, var list) in lists.enumerated() {
            list.items.sort(by: { $0.order < $1.order })
        }
    }

    func allLists() -> [ShoppingList] {
        return lists
    }

    func getList(with id: UUID) -> ShoppingList? {
        return lists.first { $0.id == id }
    }

    func addList(_ newList: ShoppingList) {
        lists.append(newList)
        lists.sort(by: { $0.order < $1.order })
    }
    
    func updateList(_ updatedList: ShoppingList) {
        if let index = lists.firstIndex(where: { $0.id == updatedList.id }) {
            lists[index] = updatedList
            lists.sort(by: { $0.order < $1.order })
        }
    }
    
    func moveList(fromOffsets offsets: IndexSet, toOffset offset: Int) {
        lists.move(fromOffsets: offsets, toOffset: offset)
        for (index, var list) in lists.enumerated() {
            list.order = index
        }
        lists.sort(by: { $0.order < $1.order })
    }

    func removeList(id: UUID) {
        lists.removeAll { $0.id == id }
    }

    // MARK: - Item management
    
    func addItem(_ item: ShoppingItem) {
        guard let listIndex = lists.firstIndex(where: { $0.id == item.listID }) else { return }
        lists[listIndex].items.append(item)
        lists[listIndex].items.sort(by: { $0.order < $1.order })
    }

    func updateItem(_ item: ShoppingItem) {
        guard let listIndex = lists.firstIndex(where: { $0.id == item.listID }) else { return }
        if let itemIndex = lists[listIndex].items.firstIndex(where: { $0.id == item.id }) {
            lists[listIndex].items[itemIndex] = item
            lists[listIndex].items.sort(by: { $0.order < $1.order })
        }
    }
    
    func moveItemOnList(_ listID: UUID, fromOffsets offsets: IndexSet, toOffset offset: Int) {
        guard let listIndex = lists.firstIndex(where: { $0.id == listID }) else { return }
        lists[listIndex].items.move(fromOffsets: offsets, toOffset: offset)
        for (index, var item) in lists[listIndex].items.enumerated() {
            item.order = index
        }
        lists[listIndex].items.sort(by: { $0.order < $1.order })
    }

    func removeItem(_ item: ShoppingItem) {
        guard let listIndex = lists.firstIndex(where: { $0.id == item.listID }) else { return }
        lists[listIndex].items.removeAll { $0.id == item.id }
        lists[listIndex].items.sort(by: { $0.order < $1.order })
    }
}
