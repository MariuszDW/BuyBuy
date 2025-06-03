//
//  AppCoordinator.swift
//  BuyBuy
//
//  Created by MDW on 14/05/2025.
//

import Foundation
import SwiftUI

final class AppCoordinator: ObservableObject, AppCoordinatorProtocol {
    @Published var navigationPath = NavigationPath()
    let sheetPresenter = SheetPresenter()

    private let dependencies: AppDependencies
    private(set) var shoppingListsViewModel: ShoppingListsViewModel!
    
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
        sheetPresenter.present(.shoppingListSettings(list, isNew), onDismiss: onDismiss)
    }
    
    func openShoppingItemDetails(_ item: ShoppingItem, isNew: Bool, onDismiss: @escaping () -> Void) {
        sheetPresenter.present(.shoppintItemDetails(item, isNew), onDismiss: onDismiss)
    }
    
    func openShoppingItemImage(with imageID: String, onDismiss: @escaping () -> Void) {
        sheetPresenter.present(.shoppingItemImage(imageID), onDismiss: onDismiss)
    }
    
    func openLoyaltyCardPreview(with imageID: String, onDismiss: @escaping () -> Void) {
        sheetPresenter.present(.loyaltyCardPreview(imageID), onDismiss: onDismiss)
    }
    
    func openAbout(onDismiss: @escaping () -> Void) {
        sheetPresenter.present(.about)
    }
    
    func closeTopSheet() {
        sheetPresenter.dismissTop()
    }
    
    func closeAllSheets() {
        sheetPresenter.dismissAll()
    }
    
    func back() {
        if !navigationPath.isEmpty {
            navigationPath.removeLast()
        }
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
            
        case let .shoppingItemImage(imageID):
            FullscreenImageView(
                viewModel: FullscreenImageViewModel(
                    imageID: imageID,
                    imageType: .itemImage,
                    dataManager: self.dependencies.dataManager
                )
            )
            
        case let .loyaltyCardPreview(imageID):
            FullscreenImageView(
                viewModel: FullscreenImageViewModel(
                    imageID: imageID,
                    imageType: .cardImage,
                    dataManager: self.dependencies.dataManager
                )
            )
            
        case .about:
            AboutView()
        }
    }
}
