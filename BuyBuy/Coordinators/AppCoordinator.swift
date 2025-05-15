//
//  AppCoordinator.swift
//  BuyBuy
//
//  Created by MDW on 14/05/2025.
//

import SwiftUI

final class AppCoordinator: ObservableObject, AppCoordinatorProtocol {
    @Published var navigationPath = NavigationPath()

    func goToShoppingListDetails(_ id: UUID) {
        navigationPath.append(AppRoute.shoppingListDetails(id))
    }
    
    func back() {
        navigationPath.removeLast()
    }
    
    @ViewBuilder
    func view(for route: AppRoute) -> some View {
        switch route {
        case .shoppingLists:
            ListsView(viewModel: ListsViewModel(coordinator: self, repository: ShoppingListRepository()))
        case .shoppingListDetails(let id):
            ShoppingListView(viewModel: ShoppingListViewModel(listID: id, coordinator: self, repository: ShoppingListRepository()))
        }
    }
}
