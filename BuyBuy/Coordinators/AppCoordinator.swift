//
//  AppCoordinator.swift
//  BuyBuy
//
//  Created by MDW on 14/05/2025.
//

import Foundation
import Combine
import SwiftUI

final class AppCoordinator: ObservableObject, AppCoordinatorProtocol {
    @Published var navigationPath = NavigationPath()
    @Published var sheet: SheetRoute?
    
    private let dependencies: AppDependencies
    private(set) var shoppingListsViewModel: ShoppingListsViewModel!
    
    @MainActor
    init(dependencies: AppDependencies) {
        self.dependencies = dependencies
        self.shoppingListsViewModel = ShoppingListsViewModel(
            coordinator: self,
            repository: dependencies.repository
        )
    }
    
    func openShoppingList(_ id: UUID) {
        navigationPath.append(AppRoute.shoppingList(id))
    }
    
    func openAppSettings() {
        navigationPath.append(AppRoute.appSettings)
    }

    func openShoppingListSettings(_ list: ShoppingList, isNew: Bool, onSave: @escaping () -> Void) {
        self.sheet = .shoppingListSettings(list, isNew, onSave: onSave)
    }
    
    func openShoppingItemDetails(_ item: ShoppingItem, isNew: Bool, onSave: @escaping () -> Void) {
        sheet = .shoppintItemDetails(item, isNew, onSave: onSave)
    }
    
    func openAbout() {
        sheet = .about
    }
    
    func back() {
        navigationPath.removeLast()
    }

    @MainActor
    @ViewBuilder
    func view(for route: AppRoute) -> some View {
        switch route {
        case .shoppingLists:
            ShoppingListsView(viewModel: shoppingListsViewModel)
        case .shoppingList(let id):
            ShoppingListView(
                viewModel: ShoppingListViewModel(
                    listID: id,
                    repository: self.dependencies.repository,
                    coordinator: self,
                )
            )
        case .appSettings:
            AppSettingsView(
                viewModel: AppSettingsViewModel(coordinator: self)
            )
        }
    }

    @MainActor
    @ViewBuilder
    func sheetView(for sheet: SheetRoute) -> some View {
        switch sheet {
        case let .shoppingListSettings(list, isNew, onSave):
            ShoppingListSettingsView(
                viewModel: ShoppingListSettingsViewModel(
                    list: list,
                    isNew: isNew,
                    repository: self.dependencies.repository,
                    coordinator: self,
                    onSave: onSave
                )
            )
        case let .shoppintItemDetails(item, isNew, onSave):
            ShoppingItemDetailsView(
                viewModel: ShoppingItemDetailsViewModel(
                    item: item,
                    isNew: isNew,
                    repository: self.dependencies.repository,
                    coordinator: self,
                    onSave: onSave
                )
            )
        case .about:
            AboutView()
        }
    }
}
