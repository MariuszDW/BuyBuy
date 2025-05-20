//
//  ShoppingListViewModel.swift
//  BuyBuy
//
//  Created by MDW on 14/05/2025.
//

import Foundation
import SwiftUI

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
        loadList()
    }

    func loadList() {
        list = repository.getList(with: listID)
    }

    func addItem(_ item: ShoppingItem) {
        repository.addItem(item)
        loadList()
        coordinator.setNeedRefreshLists(true)
    }

    func updateItem(_ item: ShoppingItem) {
        repository.updateItem(item)
        loadList()
        coordinator.setNeedRefreshLists(true)
    }
    
    func removeItem(_ item: ShoppingItem) {
        repository.removeItem(item)
        loadList()
        coordinator.setNeedRefreshLists(true)
    }
    
    func back() {
        coordinator.setNeedRefreshLists(true)
        coordinator.back()
    }
    
    func toggleCollapse(ofSection section: ShoppingListSection) {
        guard let index = sections.firstIndex(where: { $0.status == section.status }) else { return }
        withAnimation {
            sections[index].isCollapsed.toggle()
        }
    }
    
    func toggleStatus(for item: ShoppingItem) {
        var updatedItem = item
        updatedItem.status = item.status.toggled()
        withAnimation {
            updateItem(updatedItem)
        }
    }
    
    // MARK: - Helpers

//    private func updateOrders() {
//        guard var items = list?.items else { return }
//        
//        for index in items.indices {
//            items[index].order = index
//            repository.updateItem(items[index])
//        }
//    }
}
