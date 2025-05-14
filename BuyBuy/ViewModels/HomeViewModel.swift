//
//  HomeViewModel.swift
//  BuyBuy
//
//  Created by MDW on 14/05/2025.
//

import Foundation

final class HomeViewModel: ObservableObject {
    private weak var coordinator: AppCoordinatorProtocol?

    init(coordinator: AppCoordinatorProtocol) {
        self.coordinator = coordinator
    }

    func createListTapped() {
        coordinator?.goToShoppingList()
    }
}
