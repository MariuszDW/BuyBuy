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
    
    init(list: ShoppingList, isNew: Bool = false, dataManager: DataManagerProtocol, coordinator: any AppCoordinatorProtocol) {
        self.shoppingList = list
        self.isNew = isNew
        self.dataManager = dataManager
        self.coordinator = coordinator
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
}
