//
//  AppCoordinator.swift
//  BuyBuy
//
//  Created by MDW on 14/05/2025.
//

import Foundation
import SwiftUI
import Combine

final class AppCoordinator: ObservableObject, AppCoordinatorProtocol {
    @Published var navigationPath = NavigationPath()
    let sheetPresenter = SheetPresenter()
    let eventPublisher = PassthroughSubject<AppEvent, Never>()
    private let dependencies: AppDependencies
        
    @MainActor
    init(dependencies: AppDependencies) {
        self.dependencies = dependencies
    }
    
    func sendEvent(_ event: AppEvent) {
        eventPublisher.send(event)
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

    func openShoppingListSettings(_ list: ShoppingList, isNew: Bool, onDismiss: ((SheetRoute) -> Void)? = nil) {
        sheetPresenter.present(.shoppingListSettings(list, isNew), onDismiss: onDismiss)
    }
    
    func openShoppingItemDetails(_ item: ShoppingItem, isNew: Bool, onDismiss: ((SheetRoute) -> Void)? = nil) {
        sheetPresenter.present(.shoppingItemDetails(item, isNew), onDismiss: onDismiss)
    }
    
    func openShoppingItemImage(with imageID: String, onDismiss: ((SheetRoute) -> Void)? = nil) {
        sheetPresenter.present(.shoppingItemImage(imageID), onDismiss: onDismiss)
    }
    
    func openLoyaltyCardPreview(with imageID: String?, onDismiss: ((SheetRoute) -> Void)? = nil) {
        sheetPresenter.present(.loyaltyCardPreview(imageID), onDismiss: onDismiss)
    }
    
    func openLoyaltyCardDetails(_ card: LoyaltyCard, isNew: Bool, onDismiss: ((SheetRoute) -> Void)? = nil) {
        sheetPresenter.present(.loyaltyCardDetails(card, isNew), onDismiss: onDismiss)
    }
    
    func openAbout() {
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
    
    func handleMemoryWarning() {
        print("Received memory warning")
        let dataManager = dependencies.dataManager
        Task { @MainActor in
            await dataManager.cleanImageCache()
        }
    }

    @MainActor
    @ViewBuilder
    func view(for route: AppRoute) -> some View {
        switch route {
        case .shoppingLists:
            ShoppingListsView(
                viewModel: ShoppingListsViewModel(
                    coordinator: self,
                    dataManager: dependencies.dataManager
                )
            )
            
        case .shoppingList(let id):
            ShoppingListView(
                viewModel: ShoppingListViewModel(
                    listID: id,
                    dataManager: self.dependencies.dataManager,
                    coordinator: self
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
            
        case let .shoppingItemDetails(item, isNew):
            ShoppingItemDetailsView(
                viewModel: ShoppingItemDetailsViewModel(
                    item: item,
                    isNew: isNew,
                    dataManager: self.dependencies.dataManager,
                    coordinator: self
                )
            )
            
        case let .shoppingItemImage(imageID):
            FullScreenImageView(
                viewModel: FullScreenImageViewModel(
                    imageID: imageID,
                    imageType: .itemImage,
                    dataManager: self.dependencies.dataManager
                )
            )
            
        case let .loyaltyCardPreview(imageID):
            FullScreenImageView(
                viewModel: FullScreenImageViewModel(
                    imageID: imageID,
                    imageType: .cardImage,
                    dataManager: self.dependencies.dataManager
                )
            )
            
        case let .loyaltyCardDetails(card, isNew):
            LoyaltyCardDetailsView(
                viewModel: LoyaltyCardDetailsViewModel(
                    card: card,
                    isNew: isNew,
                    dataManager: self.dependencies.dataManager,
                    coordinator: self
                )
            )
            
        case .about:
            AboutView()
        }
    }
}
