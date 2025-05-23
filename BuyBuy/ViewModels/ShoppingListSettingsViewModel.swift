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
    
    /// Called when the user confirms changes to the edited ShoppingList by tapping the OK button.
    private let onSave: () -> Void
    
    private let repository: ShoppingListsRepositoryProtocol
    private let coordinator: any AppCoordinatorProtocol

    init(list: ShoppingList, isNew: Bool = false, repository: ShoppingListsRepositoryProtocol, coordinator: any AppCoordinatorProtocol, onSave: @escaping () -> Void) {
        self.shoppingList = list
        self.isNew = isNew
        self.repository = repository
        self.coordinator = coordinator
        self.onSave = onSave
    }

    func applyChanges() async {
        shoppingList.prepareToSave()
        try? await repository.addOrUpdateList(self.shoppingList)
        onSave()
    }
}
