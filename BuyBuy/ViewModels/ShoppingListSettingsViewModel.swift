//
//  ShoppingListSettingsViewModel.swift
//  BuyBuy
//
//  Created by MDW on 17/05/2025.
//

import Foundation

@MainActor
final class ShoppingListSettingsViewModel: ObservableObject {
    /// The shopping list being edited.
    @Published var shoppingList: ShoppingList
    
    /// Indicates whether the edited shopping item is a newly created one.
    private(set) var isNew: Bool
    
    var sharingAvailable: Bool {
        !isNew && dataManager.cloud
    }
    
//    var isShared: Bool {
//        !isNew && dataManager.cloud && shoppingList.isShared
//    }
    
//    var isOwner: Bool {
//        !isNew && dataManager.cloud && shoppingList.isOwner
//    }
    
//    var sharingParticipants: [SharingParticipantInfo] {
//        shoppingList.sharingParticipants
//    }
    
    var changesConfirmed: Bool = false
    
    private let dataManager: DataManagerProtocol
    let coordinator: any AppCoordinatorProtocol
    
    private var observerRegistered = false
    
    init(list: ShoppingList, isNew: Bool = false, dataManager: DataManagerProtocol, coordinator: any AppCoordinatorProtocol) {
        self.shoppingList = list
        self.isNew = isNew
        self.dataManager = dataManager
        self.coordinator = coordinator
    }
    
    func startObserving() {
        guard !observerRegistered else { return }
        dataManager.persistentStoreChangeObserver.addObserver(self) { [weak self] in
            guard let self else { return }
            await self.loadList()
        }
        observerRegistered = true
        AppLogger.general.debug("ShoppingListSettingsViewModel - Started observing remote changes")
    }
    
    func stopObserving() {
        guard observerRegistered else { return }
        dataManager.persistentStoreChangeObserver.removeObserver(self)
        observerRegistered = false
        AppLogger.general.debug("ShoppingListSettingsViewModel - Stopped observing remote changes")
    }
    
    var canConfirm: Bool {
        !shoppingList.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    func finalizeInput() {
        shoppingList.prepareToSave()
    }
    
    func didFinishEditing() async {
        if changesConfirmed {
            finalizeInput()
            try? await dataManager.addOrUpdateShoppingList(shoppingList)
        } else if isNew == true {
            try? await dataManager.deleteShoppingList(with: shoppingList.id, moveItemsToDeleted: false)
        }
        coordinator.sendEvent(.shoppingListEdited)
    }
    
    private func loadList() async {
        AppLogger.general.debug("ShoppingListSettingsViewModel.loadList() called")
        guard let newShoppingList = try? await dataManager.fetchShoppingList(with: shoppingList.id) else { return }
        if shoppingList != newShoppingList {
            shoppingList = newShoppingList
        }
    }
}
