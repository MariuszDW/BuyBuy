//
//  ShoppingListViewModel.swift
//  BuyBuy
//
//  Created by MDW on 14/05/2025.
//

import Foundation

final class ShoppingListViewModel: ObservableObject {
    @Published var list: ShoppingList?
    private weak var coordinator: AppCoordinatorProtocol?
    private var repository: ShoppingListRepositoryProtocol

    init(listID: UUID, coordinator: AppCoordinatorProtocol, repository: ShoppingListRepositoryProtocol) {
        self.coordinator = coordinator
        self.repository = repository
        self.list = repository.fetchList(by: listID)
    }

    func back() {
        coordinator?.back()
    }
}
