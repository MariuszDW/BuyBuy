//
//  ShoppingListSettingsViewModel.swift
//  BuyBuy
//
//  Created by MDW on 17/05/2025.
//

import Foundation

@MainActor
final class ShoppingListSettingsViewModel: ObservableObject {
    @Published var list: ShoppingList
    
    private(set) var isNew: Bool
    private let coordinator: any AppCoordinatorProtocol
    private let repository: ShoppingListsRepositoryProtocol
    private let onSave: () -> Void

    init(list: ShoppingList, isNew: Bool = false, repository: ShoppingListsRepositoryProtocol, coordinator: any AppCoordinatorProtocol, onSave: @escaping () -> Void) {
        self.list = list
        self.isNew = isNew
        self.repository = repository
        self.coordinator = coordinator
        self.onSave = onSave
    }

    func applyChanges() async {
        list.prepareToSave()
        if isNew {
            try? await repository.addList(self.list)
        } else {
            try? await repository.updateList(self.list)
        }
        onSave()
    }
}
