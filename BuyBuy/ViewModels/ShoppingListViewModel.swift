//
//  ShoppingListViewModel.swift
//  BuyBuy
//
//  Created by MDW on 14/05/2025.
//

import Foundation
import SwiftUI

final class ShoppingListViewModel: ObservableObject {
    private let repository: ShoppingListRepositoryProtocol
    private var coordinator: any AppCoordinatorProtocol

    @Published var list: ShoppingList?
    
    @Published var sections: [ShoppingListSection] = [
        ShoppingListSection(status: .pending),
        ShoppingListSection(status: .purchased),
        ShoppingListSection(status: .inactive)
    ]

    init(coordinator: any AppCoordinatorProtocol, repository: ShoppingListRepositoryProtocol) {
        self.coordinator = coordinator
        self.repository = repository
        loadList()
    }

    func loadList() {
        list = repository.getItems()
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

    func removeItem(with id: UUID) {
        repository.removeItem(with: id)
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
}
