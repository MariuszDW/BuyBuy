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
    
    private(set) var isNew: Bool // TODO: It's not necessary now. Remove?
    private let onSave: () -> Void
    
    private let coordinator: any AppCoordinatorProtocol
    private let repository: ShoppingListsRepositoryProtocol

    init(list: ShoppingList, isNew: Bool = false, repository: ShoppingListsRepositoryProtocol, coordinator: any AppCoordinatorProtocol, onSave: @escaping () -> Void) {
        self.list = list
        self.isNew = isNew
        self.repository = repository
        self.coordinator = coordinator
        self.onSave = onSave
    }

    func applyChanges() async {
        list.prepareToSave()
        try? await repository.addOrUpdateList(self.list)
        onSave()
    }
}
