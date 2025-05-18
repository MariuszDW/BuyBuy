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
    
    /// The result of editing. Nil means the editing was cancelled.
    @Published var result: ShoppingList? = nil
    
    /// Indicates whether the edited list is a newly created one.
    private(set) var isNew: Bool

    private let repository: ListsRepositoryProtocol
    

    init(list: ShoppingList, repository: ListsRepositoryProtocol, isNew: Bool = false) {
        self.list = list
        self.isNew = isNew
        self.repository = repository
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
