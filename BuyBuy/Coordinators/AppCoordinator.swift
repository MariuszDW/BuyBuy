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
    @Published var needRefreshLists = true
//    @Published var needRefreshList = true
    
    private let dependencies: AppDependencies
    
    private lazy var shoppingListsViewModel: ShoppingListsViewModel = {
        ShoppingListsViewModel(
            coordinator: self,
            repository: ShoppingListsRepository(store: dependencies.shoppingListsStore)
        )
    }()
    
    var needRefreshListsPublisher: AnyPublisher<Bool, Never> {
        $needRefreshLists.eraseToAnyPublisher()
    }

    init(dependencies: AppDependencies) {
        self.dependencies = dependencies
    }
    
    func setNeedRefreshLists(_ state: Bool) {
        guard state != needRefreshLists else { return }
        needRefreshLists = state
    }

    func openList(_ id: UUID) {
        navigationPath.append(AppRoute.shoppingList(id))
    }
    
    func openSettings() {
        navigationPath.append(AppRoute.settings)
    }

    func openListSettings(_ list: ShoppingList, isNew: Bool) {
        sheet = .shoppingListSettings(list, isNew)
    }
    
    func openItemDetails(_ item: ShoppingItem, isNew: Bool) {
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
                    repository: ShoppingListsRepository(store: self.dependencies.shoppingListsStore),
                    coordinator: self,
                )
            )
        case .settings:
            SettingsView(
                viewModel: SettingsViewModel(coordinator: self)
            )
        }
    }

    @MainActor
    @ViewBuilder
    func sheetView(for sheet: SheetRoute) -> some View {
        switch sheet {
        case .shoppingListSettings(let list, let isNew):
            ShoppingListSettingsView(
                viewModel: ShoppingListSettingsViewModel(
                    list: list,
                    isNew: isNew,
                    repository: ShoppingListsRepository(store: dependencies.shoppingListsStore),
                    coordinator: self
                )
            )
        case .shoppintItemDetails(let item, let isNew):
            ShoppingItemDetailsView(
                viewModel: ShoppingItemDetailsViewModel(
                    item: item,
                    isNew: isNew,
                    repository: ShoppingListsRepository(store: self.dependencies.shoppingListsStore),
                    coordinator: self)
            )
        case .about:
            AboutView()
        }
    }
}
