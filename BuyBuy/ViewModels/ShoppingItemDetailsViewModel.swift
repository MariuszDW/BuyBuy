//
//  ShoppingItemDetailsViewModel.swift
//  BuyBuy
//
//  Created by MDW on 20/05/2025.
//

import Foundation
import SwiftUI

final class ShoppingItemDetailsViewModel: ObservableObject {
    /// The shopping item being edited.
    @Published var shoppingItem: ShoppingItem
    
    /// Indicates whether the edited list is a newly created one.
    private(set) var isNew: Bool
    
    private let repository: ShoppingListsRepositoryProtocol
    private var coordinator: any AppCoordinatorProtocol
    
    init(item: ShoppingItem, isNew: Bool = false, repository: ShoppingListsRepositoryProtocol, coordinator: any AppCoordinatorProtocol) {
        self.shoppingItem = item
        self.isNew = isNew
        self.coordinator = coordinator
        self.repository = repository
    }
    
    func applyChanges() {
        shoppingItem.prepareToSave()
        if isNew {
            repository.addItem(shoppingItem)
        } else {
            repository.updateItem(shoppingItem)
        }
        coordinator.setNeedRefreshLists(true)
    }
}
