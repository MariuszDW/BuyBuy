//
//  ListsViewModel.swift
//  BuyBuy
//
//  Created by MDW on 14/05/2025.
//

import Foundation
import Combine

final class ListsViewModel: ObservableObject {
    @Published var shoppingLists: [ShoppingList] = []

    private weak var coordinator: AppCoordinatorProtocol?
    private var repository: ListsRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()

    init(coordinator: AppCoordinatorProtocol, repository: ListsRepositoryProtocol) {
        self.coordinator = coordinator
        self.repository = repository
        loadLists()
    }

    private func loadLists() {
        shoppingLists = repository.fetchAllLists()
    }
    
    func listTapped(_ list: ShoppingList) {
        coordinator?.goToShoppingListDetails(list.id)
    }
}
