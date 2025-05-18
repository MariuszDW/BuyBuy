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
    
    private let dependencies: AppDependencies
    
    private lazy var listsViewModel: ListsViewModel = {
        ListsViewModel(
            coordinator: self,
            repository: ListsRepository(store: dependencies.shoppingListStore)
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
        sheet = .listSettings(list, isNew)
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
            ListsView(viewModel: listsViewModel)
        case .shoppingList(let id):
            ShoppingListView(
                viewModel: ShoppingListViewModel(
                    coordinator: self,
                    repository: ShoppingListRepository(listID: id, store: dependencies.shoppingListStore)
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
        case .listSettings(let list, let isNew):
            ListSettingsView(
                viewModel: ListSettingsViewModel(
                    coordinator: self,
                    list: list,
                    repository: ListsRepository(store: dependencies.shoppingListStore),
                    isNew: isNew
                )
            )
        case .about:
            AboutView()
        }
    }
}
