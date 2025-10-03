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
    private var preferences: AppPreferencesProtocol
    private var userActivityTracker: any UserActivityTrackerProtocol
    let coordinator: any AppCoordinatorProtocol
    private var observerRegistered = false

    init(dataManager: DataManagerProtocol, userActivityTracker: any UserActivityTrackerProtocol, coordinator: any AppCoordinatorProtocol, preferences: AppPreferencesProtocol) {
        self.dataManager = dataManager
        self.userActivityTracker = userActivityTracker
        self.coordinator = coordinator
        self.preferences = preferences
    }
    
    func startObserving() {
        guard !observerRegistered else { return }
        dataManager.persistentStoreChangeObserver.addObserver(self) { [weak self] in
            guard let self else { return }
            await self.loadLists()
        }
        observerRegistered = true
        AppLogger.general.debug("ShoppingListsViewModel - Started observing remote changes")
    }
    
    func stopObserving() {
        guard observerRegistered else { return }
        dataManager.persistentStoreChangeObserver.removeObserver(self)
        observerRegistered = false
        AppLogger.general.debug("ShoppingListsViewModel - Stopped observing remote changes")
    }
    
    var isCloud: Bool {
        dataManager.cloud
    }
    
    var shouldShowTipJarButton: Bool {
        userActivityTracker.shouldShowTipReminder
    }
    
    func loadLists(fullRefresh: Bool = false) async {
        AppLogger.general.debug("ShoppingListsViewModel.loadLists(fullRefresh: \(fullRefresh, privacy: .public))")
        if fullRefresh {
            await dataManager.refreshAllCloudData()
        }
        guard let newShoppingLists = try? await dataManager.fetchShoppingLists() else { return }
        
        let ordered = sortLists(newShoppingLists)
        if shoppingLists != ordered {
            shoppingLists = ordered
            saveCurrentOrder()
        }
    }

    func deleteLists(atOffsets offsets: IndexSet) async {
        let idsToDelete = offsets.map { shoppingLists[$0].id }
        shoppingLists.removeAll { idsToDelete.contains($0.id) }
        preferences.shoppingListsOrder.removeAll { idsToDelete.contains($0) }
        
        try? await dataManager.deleteShoppingLists(with: idsToDelete, moveItemsToDeleted: true)
        await loadLists()
    }

    func deleteList(id: UUID) async {
        shoppingLists.removeAll { $0.id == id }
        preferences.shoppingListsOrder.removeAll { $0 == id }
        
        try? await dataManager.deleteShoppingList(with: id, moveItemsToDeleted: true)
        await loadLists()
    }

    func moveLists(fromOffsets source: IndexSet, toOffset destination: Int) async {
        shoppingLists.move(fromOffsets: source, toOffset: destination)
        saveCurrentOrder()
    }
    
    func openNewListSettings() {
        let list = ShoppingList(id: UUID(), name: "", items: [], icon: .default, color: .default)
        coordinator.openShoppingListSettings(list, isNew: true, onDismiss: nil)
    }
    
    func openListSettings(for list: ShoppingList) {
        coordinator.openShoppingListSettings(list, isNew: false, onDismiss: nil)
    }
    
    func openShareManagement(for list: ShoppingList) {
        Task {
            await coordinator.openShoppingListShareManagement(with: list.id, title: list.name, onDismiss: { _ in })
        }
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
        coordinator.openTipJar(onDismiss: { _ in })
    }

    // MARK: - Private helpers
    
    private func sortLists(_ lists: [ShoppingList]) -> [ShoppingList] {
        let order = preferences.shoppingListsOrder
        var dict = [UUID: ShoppingList]()
        lists.forEach { dict[$0.id] = $0 }
        
        var result: [ShoppingList] = []
        
        for id in order {
            if let list = dict.removeValue(forKey: id) {
                result.append(list)
            }
        }
        
        if !dict.isEmpty {
            result.append(contentsOf: dict.values.sorted { $0.id.uuidString < $1.id.uuidString })
        }
        
        return result
    }
    
    private func saveCurrentOrder() {
        preferences.shoppingListsOrder = shoppingLists.map(\.id)
    }
}
