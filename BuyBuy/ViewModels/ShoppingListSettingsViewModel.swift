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
    
    private let repository: ShoppingListsRepositoryProtocol
    private let coordinator: any AppCoordinatorProtocol

    init(list: ShoppingList, isNew: Bool = false, repository: ShoppingListsRepositoryProtocol, coordinator: any AppCoordinatorProtocol) {
        self.shoppingList = list
        self.isNew = isNew
        self.repository = repository
        self.coordinator = coordinator
    }

    func applyChanges() async {
        shoppingList.prepareToSave()
        try? await repository.addOrUpdateList(self.shoppingList)
    }
}
