//
//  ShoppingListViewModel.swift
//  BuyBuy
//
//  Created by MDW on 14/05/2025.
//

import Foundation

final class ShoppingListViewModel: ObservableObject {
    private let repository: ShoppingListRepositoryProtocol
    private var coordinator: any AppCoordinatorProtocol

    @Published var list: ShoppingList?
    
    @Published var sections: [ShoppingListSection] = [
        .pending,
        .purchased,
        .inactive
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
}
