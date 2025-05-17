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
    }

    func allLists() -> [ShoppingList] {
        return lists.sorted(by: { $0.order < $1.order })
    }

    func fetchList(with id: UUID) -> ShoppingList? {
        return lists.first { $0.id == id }
    }

    func updateList(_ updatedList: ShoppingList) {
        print("updateList '\(updatedList.name)'")
        if let index = lists.firstIndex(where: { $0.id == updatedList.id }) {
            lists[index] = updatedList
            lists.sort(by: { $0.order < $1.order })
        }
    }

    func addList(_ newList: ShoppingList) {
        print("addList '\(newList.name)'")
        var listWithOrder = newList
        let maxOrder = lists.map { $0.order }.max() ?? -1
        listWithOrder.order = maxOrder + 1
        lists.append(listWithOrder)
    }

    func removeList(id: UUID) {
        print("removeList id='\(id)'")
        lists.removeAll { $0.id == id }
    }

    func moveList(fromOffsets offsets: IndexSet, toOffset offset: Int) {
        lists.move(fromOffsets: offsets, toOffset: offset)
        for (index, var list) in lists.enumerated() {
            list.order = index
            updateList(list)
        }
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
