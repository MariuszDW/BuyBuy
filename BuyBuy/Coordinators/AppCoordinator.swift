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
    @Published var needRefreshLists = false
    
    var needRefreshListsPublisher: AnyPublisher<Bool, Never> {
        $needRefreshLists.eraseToAnyPublisher()
    }

    // private var cancellables = Set<AnyCancellable>()
    private var sheetCancellable: AnyCancellable?

    let dependencies: AppDependencies

    init(dependencies: AppDependencies) {
        self.dependencies = dependencies
    }
    
    func resetNeedRefreshListsFlag() {
        needRefreshLists = false
    }

    func openList(_ id: UUID) {
        navigationPath.append(AppRoute.shoppingList(id))
    }
    
    func openSettings() {
        navigationPath.append(AppRoute.settings)
    }
    
    func back() {
        navigationPath.removeLast()
    }

    func openListSettings(_ list: ShoppingList, isNew: Bool) {
        let viewModel = ListSettingsViewModel(
            list: list,
            repository: ListsRepository(store: dependencies.shoppingListStore),
            isNew: isNew
        )
        
        sheetCancellable = viewModel.$result
            .sink { [weak self] updatedList in
                guard let self = self else { return }
                if updatedList != nil {
                    self.needRefreshLists = true
                }
                self.sheetCancellable?.cancel()
                self.sheetCancellable = nil
            }
        
        sheet = .listSettings(viewModel)
    }
    
    func openAbout() {
        sheet = .about
    }

    @MainActor
    @ViewBuilder
    func view(for route: AppRoute) -> some View {
        switch route {
        case .shoppingLists:
            ListsView(
                viewModel: ListsViewModel(
                    coordinator: self,
                    repository: ListsRepository(store: dependencies.shoppingListStore)
                )
            )
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
        case .listSettings(let viewModel):
            ListSettingsView(viewModel: viewModel)
        case .about:
            AboutView()
        }
    }
}
