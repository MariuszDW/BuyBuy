//
//  ShoppingItemDetailsViewModel.swift
//  BuyBuy
//
//  Created by MDW on 20/05/2025.
//

import Foundation

@MainActor
final class ShoppingItemDetailsViewModel: ObservableObject {
    /// The shopping item being edited.
    @Published var shoppingItem: ShoppingItem
    
    /// Indicates whether the edited list is a newly created one.
    private(set) var isNew: Bool
    private let onSave: () -> Void
    
    private let repository: ShoppingListsRepositoryProtocol
    private var coordinator: any AppCoordinatorProtocol
    
    init(item: ShoppingItem, isNew: Bool = false, repository: ShoppingListsRepositoryProtocol, coordinator: any AppCoordinatorProtocol, onSave: @escaping () -> Void) {
        self.shoppingItem = item
        self.isNew = isNew
        self.coordinator = coordinator
        self.repository = repository
        self.onSave = onSave
    }
    
    func applyChanges() async {
        shoppingItem.prepareToSave()
        if isNew {
            try? await repository.addItem(shoppingItem)
        } else {
            try? await repository.updateItem(shoppingItem)
        }
        onSave()
    }
}
