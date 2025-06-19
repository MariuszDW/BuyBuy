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
    let coordinator: any AppCoordinatorProtocol
    
    lazy var remoteChangeObserver: PersistentStoreChangeObserver = {
        PersistentStoreChangeObserver { [weak self] in
            guard let self = self else { return }
            await self.loadLists()
        }
    }()

    init(dataManager: DataManagerProtocol, coordinator: any AppCoordinatorProtocol) {
        self.coordinator = coordinator
        self.dataManager = dataManager
    }
    
    func startObserving() {
        remoteChangeObserver.startObserving()
        print("ShoppingListsViewModel - Started observing remote changes") // TODO: temp
    }
    
    func stopObserving() {
        remoteChangeObserver.stopObserving()
        print("ShoppingListsViewModel - Stopped observing remote changes") // TODO: temp
    }
    
    func loadLists() async {
        print("ShoppingListsViewModel - loadLists") // TODO: temp
        guard let newShoppingLists = try? await dataManager.fetchAllLists() else { return }
        if shoppingLists != newShoppingLists {
            shoppingLists = newShoppingLists
        }
    }

    func deleteLists(atOffsets offsets: IndexSet) async {
        let idsToDelete = offsets.map { shoppingLists[$0].id }
        shoppingLists.removeAll { idsToDelete.contains($0.id) }
        try? await dataManager.deleteLists(with: idsToDelete, moveItemsToDeleted: true)
        await loadLists()
    }

    func deleteList(id: UUID) async {
        shoppingLists.removeAll { $0.id == id }
        try? await dataManager.deleteList(with: id, moveItemsToDeleted: true)
        await loadLists()
    }

    func moveLists(fromOffsets source: IndexSet, toOffset destination: Int) async {
        shoppingLists.move(fromOffsets: source, toOffset: destination)
        for index in shoppingLists.indices {
            shoppingLists[index].order = index
            try? await dataManager.addOrUpdateList(shoppingLists[index])
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

    func openAbout() {
        coordinator.openAbout()
    }

    func openSettings() {
        coordinator.openAppSettings()
    }
    
    func openLoyaltyCards() {
        coordinator.openLoyaltyCardList()
    }
}
