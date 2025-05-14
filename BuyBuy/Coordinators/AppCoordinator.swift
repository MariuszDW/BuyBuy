//
//  AppCoordinator.swift
//  BuyBuy
//
//  Created by MDW on 14/05/2025.
//

import SwiftUI

final class AppCoordinator: ObservableObject, AppCoordinatorProtocol {
    @Published var navigationPath = NavigationPath()

    // Funkcja do przejścia do listy zakupów
    func goToShoppingList() {
        navigationPath.append(AppRoute.shoppingList)
    }

    // Funkcja do zarządzania powrotem (usuwanie ostatniego elementu ze ścieżki)
    func back() {
        navigationPath.removeLast()
    }

    // Funkcja do renderowania widoków na podstawie trasy
    func view(for route: AppRoute) -> some View {
        switch route {
        case .shoppingList:
            let viewModel = ShoppingListViewModel(coordinator: self)
            return ShoppingListView(viewModel: viewModel)
        }
        // Można dodać kolejne przypadki dla innych ekranów
        // case .otherRoute:
        //     return OtherView()
    }
}
