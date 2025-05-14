//
//  ShoppingListViewModel.swift
//  BuyBuy
//
//  Created by MDW on 14/05/2025.
//

import Foundation

final class ShoppingListViewModel: ObservableObject {
    private weak var coordinator: AppCoordinatorProtocol?

    init(coordinator: AppCoordinatorProtocol) {
        self.coordinator = coordinator
    }

    func back() {
        coordinator?.back()
    }
}
