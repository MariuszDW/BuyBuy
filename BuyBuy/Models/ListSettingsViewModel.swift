//
//  ListSettingsViewModel.swift
//  BuyBuy
//
//  Created by MDW on 17/05/2025.
//

import Foundation
import Combine

final class ListSettingsViewModel: ObservableObject {
    /// The list being edited.
    @Published var list: ShoppingList
    
    /// Indicates whether the edited list is a newly created one.
    private(set) var isNew: Bool

    private let coordinator: any AppCoordinatorProtocol
    private let repository: ListsRepositoryProtocol

    init(coordinator: any AppCoordinatorProtocol, list: ShoppingList, repository: ListsRepositoryProtocol, isNew: Bool = false) {
        self.list = list
        self.isNew = isNew
        self.repository = repository
        self.coordinator = coordinator
    }

    func applyChanges() {
        if isNew {
            repository.addList(list)
        } else {
            repository.updateList(list)
        }
        coordinator.setNeedRefreshLists(true)
    }
}
