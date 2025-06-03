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
            dataManager: dependencies.dataManager
        )
    }
    
    @MainActor
    func performStartupTasks() async {
        try? await dependencies.dataManager.cleanOrphanedItems()
        try? await dependencies.dataManager.cleanOrphanedItemImages()
        try? await dependencies.dataManager.cleanOrphanedCardImages()
    }
    
    func openShoppingList(_ id: UUID) {
        navigationPath.append(AppRoute.shoppingList(id))
    }
    
    func openAppSettings() {
        navigationPath.append(AppRoute.appSettings)
    }
    
    func openLoyaltyCardList() {
        navigationPath.append(AppRoute.loyaltyCards)
    }

    func openShoppingListSettings(_ list: ShoppingList, isNew: Bool, onDismiss: @escaping () -> Void) {
        onSheetDismissed = onDismiss
        sheet = .shoppingListSettings(list, isNew)
    }
    
    func openShoppingItemDetails(_ item: ShoppingItem, isNew: Bool, onDismiss: @escaping () -> Void) {
        onSheetDismissed = onDismiss
        sheet = .shoppintItemDetails(item, isNew)
    }
    
    func openLoyaltyCardPreview(with imageID: String) {
        sheet = .loyaltyCardPreview(imageID)
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
                    dataManager: self.dependencies.dataManager,
                    coordinator: self,
                )
            )
            
        case .appSettings:
            AppSettingsView(
                viewModel: AppSettingsViewModel(dataManager: self.dependencies.dataManager,
                                                coordinator: self)
            )
            
        case .loyaltyCards:
            LoyaltyCardsView(viewModel: LoyaltyCardsViewModel(dataManager: self.dependencies.dataManager,
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
                    dataManager: self.dependencies.dataManager,
                    coordinator: self
                )
            )
            
        case let .shoppintItemDetails(item, isNew):
            ShoppingItemDetailsView(
                viewModel: ShoppingItemDetailsViewModel(
                    item: item,
                    isNew: isNew,
                    dataManager: self.dependencies.dataManager,
                    coordinator: self
                )
            )
            
        case let .loyaltyCardPreview(imageID):
            FullscreenImageView(
                viewModel: FullscreenImageViewModel(
                    imageID: imageID,
                    imageType: .card,
                    dataManager: self.dependencies.dataManager
                )
            )
            
        case .about:
            AboutView()
        }
    }
}
