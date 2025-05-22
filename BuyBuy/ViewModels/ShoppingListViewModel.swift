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
    }
    
    func addItem(_ item: ShoppingItem) async {
        try? await repository.addItem(item)
        await loadList()
    }
    
    func updateItem(_ item: ShoppingItem) async {
        try? await repository.updateItem(item)
        await loadList()
    }
    
    func deleteItem(_ item: ShoppingItem) async {
        try? await repository.deleteItem(item)
        await loadList()
    }
    
    func back() {
        coordinator.back()
    }
    
    func toggleCollapse(ofSection section: ShoppingListSection) {
        guard let index = sections.firstIndex(where: { $0.status == section.status }) else { return }
        withAnimation {
            sections[index].isCollapsed.toggle()
        }
    }
    
    func toggleStatus(for item: ShoppingItem) async {
        var updatedItem = item
        updatedItem.status = item.status.toggled()
        await updateItem(updatedItem)
    }
    
    func openNewItemSettings(listID: UUID) {
        let uniqueUUID = UUID.unique(in: list?.items.map { $0.id })
        let maxOrder = list?.items.map(\.order).max() ?? 0
        let newItem = ShoppingItem(id: uniqueUUID, order: maxOrder + 1, listID: listID, name: "", status: .pending)
        
        coordinator.openShoppingItemDetails(newItem, isNew: true, onSave: { [weak self] in
            Task {
                await self?.loadList()
            }
        })
    }
    
    func openItemSettings(item: ShoppingItem) {
        coordinator.openShoppingItemDetails(item, isNew: false, onSave: { [weak self] in
            Task {
                await self?.loadList()
            }
        })
    }
}
