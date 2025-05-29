//
//  ShoppingListViewModel.swift
//  BuyBuy
//
//  Created by MDW on 14/05/2025.
//

import Foundation
import SwiftUI

@MainActor
final class ShoppingListViewModel: ObservableObject {
    private let repository: ShoppingListsRepositoryProtocol
    private var coordinator: any AppCoordinatorProtocol
    
    private let listID: UUID
    @Published var list: ShoppingList?
    
    @Published var sections: [ShoppingListSection] = [
        ShoppingListSection(status: .pending),
        ShoppingListSection(status: .purchased),
        ShoppingListSection(status: .inactive)
    ]
    
    init(listID: UUID, repository: ShoppingListsRepositoryProtocol, coordinator: any AppCoordinatorProtocol) {
        self.listID = listID
        self.repository = repository
        self.coordinator = coordinator
    }
    
    func loadList() async {
        let fetchedList = try? await repository.fetchList(with: listID)
        self.list = fetchedList
        
        // TODO: temporary test or order
//        let pending = self.list?.items(for: .pending)
//        let purchased = self.list?.items(for: .purchased)
//        print("pending:")
//        pending?.forEach { item in
//            print("    \(item.name), order=\(item.order)")
//        }
//        print("purchased:")
//        purchased?.forEach { item in
//            print("    \(item.name), order=\(item.order)")
//        }
//        print("-------------")
    }
    
    func addOrUpdateItem(_ item: ShoppingItem) async {
        try? await repository.addOrUpdateItem(item)
        await loadList()
    }
    
    func deleteItem(with id: UUID) async {
        try? await repository.deleteItem(with: id)
        await loadList()
    }
    
    func moveItem(from source: IndexSet, to destination: Int, in section: ShoppingItemStatus) async {
        guard let list = list else { return }
        
        var items = list.items(for: section)
        items.move(fromOffsets: source, toOffset: destination)

        let reorderedItems = items.enumerated().map { index, item -> ShoppingItem in
            var updatedItem = item
            updatedItem.order = index
            return updatedItem
        }

        for item in reorderedItems {
            try? await repository.addOrUpdateItem(item)
        }

        await loadList()
    }
    
    func back() {
        coordinator.back()
    }
    
    func deleteItems(atOffsets offsets: IndexSet, section: ShoppingListSection) async {
        guard let items = list?.items(for: section.status) else { return }
        let idsToDelete = offsets.map { items[$0].id }
        list?.items.removeAll { idsToDelete.contains($0.id) }
        try? await repository.deleteItems(with: idsToDelete)
        await loadList()
    }
    
    func toggleCollapse(ofSection section: ShoppingListSection) {
        guard let index = sections.firstIndex(where: { $0.status == section.status }) else { return }
        withAnimation {
            sections[index].isCollapsed.toggle()
        }
    }
    
    func toggleStatus(for item: ShoppingItem) async {
        await setStatus(item.status.toggled(), forItem: item)
    }
    
    func setStatus(_ status: ShoppingItemStatus, forItem item: ShoppingItem) async {
        guard var currentList = self.list else { return }
        guard let oldItemIndex = currentList.items.firstIndex(where: { $0.id == item.id }) else { return }
        
        var updatedItem = currentList.items[oldItemIndex]
        let oldStatus = updatedItem.status
        
        guard oldStatus != status else { return }
        
        updatedItem.status = status
        
        currentList.items[oldItemIndex] = updatedItem
        
        var oldSectionItems = currentList.items(for: oldStatus)
            .filter { $0.id != updatedItem.id }
        
        var newSectionItems = currentList.items(for: status)
            .filter { $0.id != updatedItem.id }
        
        let maxOrder = newSectionItems.map(\.order).max() ?? -1
        updatedItem.order = maxOrder + 1
        
        newSectionItems.append(updatedItem)
        
        newSectionItems = newSectionItems.enumerated().map { index, item in
            var mutable = item
            mutable.order = index
            return mutable
        }
        
        oldSectionItems = oldSectionItems.enumerated().map { index, item in
            var mutable = item
            mutable.order = index
            return mutable
        }
        
        self.list = currentList
        
        for item in newSectionItems {
            try? await repository.addOrUpdateItem(item)
        }
        
        for item in oldSectionItems {
            try? await repository.addOrUpdateItem(item)
        }
        
        await loadList()
    }
    
    func openNewItemSettings(listID: UUID) {
        let newItemStatus: ShoppingItemStatus = .pending
        let uniqueUUID = UUID.unique(in: list?.items.map { $0.id })
        let maxOrder = list?.items(for: newItemStatus).map(\.order).max() ?? 0
        
        let newItem = ShoppingItem(id: uniqueUUID, order: maxOrder + 1, listID: listID, name: "", status: newItemStatus)
        
        coordinator.openShoppingItemDetails(newItem, isNew: true, onDismiss: { [weak self] in
            Task {
                await self?.loadList()
            }
        })
    }
    
    func openItemSettings(item: ShoppingItem) {
        coordinator.openShoppingItemDetails(item, isNew: false, onDismiss: { [weak self] in
            Task {
                await self?.loadList()
            }
        })
    }
}
