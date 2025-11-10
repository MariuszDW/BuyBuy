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
    @Published var selectedStatus: ShoppingItemStatus = .pending
    
    private let itemID: UUID
    private let dataManager: DataManagerProtocol
    private var coordinator: (any AppCoordinatorProtocol)?
    
    init(itemIDToRestore: UUID, dataManager: DataManagerProtocol, coordinator: any AppCoordinatorProtocol) {
        self.itemID = itemIDToRestore
        self.dataManager = dataManager
        self.coordinator = coordinator
    }
    
    func loadLists() async {
        let fetchedLists = try? await dataManager.fetchShoppingLists()
        shoppingLists = fetchedLists ?? []
    }
    
    func moveDeletedItem(/*itemID: UUID, */ /*status: ShoppingItemStatus,*/ toListID: UUID) async {
        try? await dataManager.restoreShoppingItem(with: itemID, status: selectedStatus, toList: toListID)
        coordinator?.sendEvent(.shoppingItemEdited)
    }
}
