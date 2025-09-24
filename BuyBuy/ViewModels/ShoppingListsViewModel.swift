//
//  ShoppingListsViewModel.swift
//  BuyBuy
//
//  Created by MDW on 14/05/2025.
//

import Foundation
import Combine

@MainActor
class ShoppingListsViewModel: ObservableObject {
    @Published var shoppingLists: [ShoppingList] = []

    private let dataManager: DataManagerProtocol
    private var userActivityTracker: any UserActivityTrackerProtocol
    let coordinator: any AppCoordinatorProtocol
    private var observerRegistered = false

    init(dataManager: DataManagerProtocol, userActivityTracker: any UserActivityTrackerProtocol, coordinator: any AppCoordinatorProtocol) {
        self.coordinator = coordinator
        self.userActivityTracker = userActivityTracker
        self.dataManager = dataManager
    }
    
    func startObserving() {
        guard !observerRegistered else { return }
        dataManager.persistentStoreChangeObserver.addObserver(self) { [weak self] in
            guard let self else { return }
            await self.loadLists()
        }
        observerRegistered = true
        print("ShoppingListsViewModel - Started observing remote changes")
    }
    
    func stopObserving() {
        guard observerRegistered else { return }
        dataManager.persistentStoreChangeObserver.removeObserver(self)
        observerRegistered = false
        print("ShoppingListsViewModel - Stopped observing remote changes")
    }
    
    var isCloud: Bool {
        dataManager.cloud
    }
    
    var shouldShowTipJarButton: Bool {
        userActivityTracker.shouldShowTipReminder
    }
    
    func loadLists(fullRefresh: Bool = false) async {
        print("ShoppingListsViewModel.loadLists(fullRefresh: \(fullRefresh))")
        if fullRefresh {
            await dataManager.refreshAllCloudData()
        }
        guard let newShoppingLists = try? await dataManager.fetchShoppingLists() else { return }
        if shoppingLists != newShoppingLists {
            shoppingLists = newShoppingLists
        }
    }

    func deleteLists(atOffsets offsets: IndexSet) async {
        let idsToDelete = offsets.map { shoppingLists[$0].id }
        shoppingLists.removeAll { idsToDelete.contains($0.id) }
        try? await dataManager.deleteShoppingLists(with: idsToDelete, moveItemsToDeleted: true)
        await loadLists()
    }

    func deleteList(id: UUID) async {
        shoppingLists.removeAll { $0.id == id }
        try? await dataManager.deleteShoppingList(with: id, moveItemsToDeleted: true)
        await loadLists()
    }

    func moveLists(fromOffsets source: IndexSet, toOffset destination: Int) async {
        shoppingLists.move(fromOffsets: source, toOffset: destination)
        for index in shoppingLists.indices {
            shoppingLists[index].order = index
            try? await dataManager.addOrUpdateShoppingList(shoppingLists[index])
        }
    }
    
    func openNewListSettings() {
        let maxOrder = shoppingLists.map(\.order).max() ?? 0
        let list = ShoppingList(id: UUID(), name: "", items: [], order: maxOrder + 1, icon: .default, color: .default)
        
        coordinator.openShoppingListSettings(list, isNew: true, onDismiss: nil)
    }
    
    func openListSettings(for list: ShoppingList) {
        coordinator.openShoppingListSettings(list, isNew: false, onDismiss: nil)
    }
    
    func openShareManagement(for list: ShoppingList) async {
        await coordinator.openShoppingListShareManagement(with: list.id, title: list.name, onDismiss: {_ in })
    }

    func openAbout() {
        coordinator.openAbout()
    }

    func openSettings() {
        coordinator.openAppSettings()
    }
    
    func openLoyaltyCards() {
        coordinator.openLoyaltyCardList()
    }
    
    func openDeletedItems() {
        coordinator.openDeletedItems()
    }
    
    func openTipJar() {
        coordinator.openTipJar(onDismiss: {_ in })
    }
}
