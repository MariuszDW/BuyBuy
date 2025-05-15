//
//  AppCoordinator.swift
//  BuyBuy
//
//  Created by MDW on 14/05/2025.
//

import SwiftUI

final class AppCoordinator: ObservableObject, AppCoordinatorProtocol {
    @Published var navigationPath = NavigationPath()

    func goToShoppingList() {
        navigationPath.append(AppRoute.shoppingList)
    }

    func back() {
        navigationPath.removeLast()
    }

    func view(for route: AppRoute) -> some View {
        switch route {
        case .shoppingList:
            let viewModel = ShoppingListViewModel(coordinator: self)
            return ShoppingListView(viewModel: viewModel)
        }
        // TODO: other screns
        // case .otherRoute:
        //     return OtherView()
    }
}
