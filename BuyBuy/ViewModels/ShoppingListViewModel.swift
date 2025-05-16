//
//  ShoppingListViewModel.swift
//  BuyBuy
//
//  Created by MDW on 14/05/2025.
//

import Foundation

final class ShoppingListViewModel: ObservableObject {
    private let repository: ShoppingListRepositoryProtocol
    private weak var coordinator: AppCoordinatorProtocol?

    @Published var list: ShoppingList?

    init(coordinator: AppCoordinatorProtocol, repository: ShoppingListRepositoryProtocol) {
        self.coordinator = coordinator
        self.repository = repository
        loadList()
    }

    func loadList() {
        list = repository.fetchList()
    }

    func addItem(_ item: ShoppingItem) {
        repository.addItem(item)
        loadList()
    }

    func updateItem(_ item: ShoppingItem) {
        repository.updateItem(item)
        loadList()
    }

    func removeItem(with id: UUID) {
        repository.removeItem(with: id)
        loadList()
    }
    
    func back() {
        coordinator?.back()
    }
}

