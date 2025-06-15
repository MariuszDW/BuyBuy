//
//  ShoppingListSelectorViewModel.swift
//  BuyBuy
//
//  Created by MDW on 15/06/2025.
//

import SwiftUI

@MainActor
final class ShoppingListSelectorViewModel: ObservableObject {
    @Published var shoppingLists: [ShoppingList] = []
    let itemIDToRestore: UUID
    private let dataManager: DataManagerProtocol
    private var coordinator: any AppCoordinatorProtocol
    
    init(itemIDToRestore: UUID, dataManager: DataManagerProtocol, coordinator: any AppCoordinatorProtocol) {
        self.itemIDToRestore = itemIDToRestore
        self.dataManager = dataManager
        self.coordinator = coordinator
    }
    
    func loadLists() async {
        let fetchedLists = try? await dataManager.fetchAllLists()
        shoppingLists = fetchedLists ?? []
    }
    
    func moveDeletedItem(itemID: UUID, toList: ShoppingList) async {
        guard var item = try? await dataManager.fetchItem(with: itemID) else { return }
        item.listID = toList.id
        try? await dataManager.addOrUpdateItem(item)
        coordinator.sendEvent(.shoppingItemEdited)
    }
}
