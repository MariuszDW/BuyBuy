//
//  ListSettingsViewModel.swift
//  BuyBuy
//
//  Created by MDW on 17/05/2025.
//

import Foundation
import Combine

final class ListSettingsViewModel: ObservableObject {
    // The list being edited.
    @Published var list: ShoppingList
    // The result of editing. Nil means the editing was cancelled.
    @Published var result: ShoppingList? = nil

    private let repository: ListsRepositoryProtocol
    private let isNew: Bool

    init(list: ShoppingList, repository: ListsRepositoryProtocol, isNew: Bool = false) {
        self.list = list
        self.repository = repository
        self.isNew = isNew
    }

    func applyChanges() {
        if isNew {
            repository.addList(list)
        } else {
            repository.updateList(list)
        }
        result = list
    }
}
