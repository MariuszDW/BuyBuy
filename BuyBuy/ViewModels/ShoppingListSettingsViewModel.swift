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
    
    var changesConfirmed: Bool = false
    
    private let dataManager: DataManagerProtocol
    let coordinator: any AppCoordinatorProtocol
    
    lazy var remoteChangeObserver: PersistentStoreChangeObserver = {
        PersistentStoreChangeObserver(coreDataStack: dataManager.coreDataStack) { [weak self] in
            guard let self = self else { return }
            await self.loadList()
        }
    }()
    
    init(list: ShoppingList, isNew: Bool = false, dataManager: DataManagerProtocol, coordinator: any AppCoordinatorProtocol) {
        self.shoppingList = list
        self.isNew = isNew
        self.dataManager = dataManager
        self.coordinator = coordinator
    }
    
    func startObserving() {
        remoteChangeObserver.startObserving()
        print("ShoppingListSettingsViewModel - Started observing remote changes")
    }
    
    func stopObserving() {
        remoteChangeObserver.stopObserving()
        print("ShoppingListSettingsViewModel - Stopped observing remote changes")
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
            try? await dataManager.addOrUpdateList(shoppingList)
        } else if isNew == true {
            try? await dataManager.deleteList(with: shoppingList.id, moveItemsToDeleted: false)
        }
        coordinator.sendEvent(.shoppingListEdited)
    }
    
    private func loadList() async {
        print("ShoppingListSettingsViewModel.loadCard() called")
        guard let newShoppingList = try? await dataManager.fetchList(with: shoppingList.id) else { return }
        if shoppingList != newShoppingList {
            shoppingList = newShoppingList
        }
    }
}
