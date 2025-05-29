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
    var onSheetDismissed: (() -> Void)?
    
    @MainActor
    init(dependencies: AppDependencies) {
        self.dependencies = dependencies
        self.shoppingListsViewModel = ShoppingListsViewModel(
            coordinator: self,
            repository: dependencies.repository
        )
    }
    
    @MainActor
    func performStartupTasks() async {
        try? await dependencies.repository.cleanOrphanedItems()
    }
    
    func openShoppingList(_ id: UUID) {
        navigationPath.append(AppRoute.shoppingList(id))
    }
    
    func openAppSettings() {
        navigationPath.append(AppRoute.appSettings)
    }

    func openShoppingListSettings(_ list: ShoppingList, isNew: Bool, onDismiss: @escaping () -> Void) {
        onSheetDismissed = onDismiss
        sheet = .shoppingListSettings(list, isNew)
    }
    
    func openShoppingItemDetails(_ item: ShoppingItem, isNew: Bool, onDismiss: @escaping () -> Void) {
        onSheetDismissed = onDismiss
        sheet = .shoppintItemDetails(item, isNew)
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
                viewModel: AppSettingsViewModel(repository: self.dependencies.repository,
                                                coordinator: self)
            )
        }
    }

    @MainActor
    @ViewBuilder
    func sheetView(for sheet: SheetRoute) -> some View {
        switch sheet {
        case let .shoppingListSettings(list, isNew):
            ShoppingListSettingsView(
                viewModel: ShoppingListSettingsViewModel(
                    list: list,
                    isNew: isNew,
                    repository: self.dependencies.repository,
                    coordinator: self
                )
            )
        case let .shoppintItemDetails(item, isNew):
            ShoppingItemDetailsView(
                viewModel: ShoppingItemDetailsViewModel(
                    item: item,
                    isNew: isNew,
                    repository: self.dependencies.repository,
                    imageStorage: self.dependencies.imageStorage,
                    coordinator: self
                )
            )
        case .about:
            AboutView()
        }
    }
}
