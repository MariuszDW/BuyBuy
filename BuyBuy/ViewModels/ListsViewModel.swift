//
//  ListsViewModel.swift
//  BuyBuy
//
//  Created by MDW on 14/05/2025.
//

import Foundation
import Combine

final class ListsViewModel: ObservableObject {
    @Published var shoppingLists: [ShoppingList]

    private weak var coordinator: AppCoordinatorProtocol?
    private let repository: ListsRepositoryProtocol

    init(coordinator: AppCoordinatorProtocol?, repository: ListsRepositoryProtocol) {
        self.repository = repository
        self.coordinator = coordinator
        self.shoppingLists = repository.fetchAllLists()
    }

    func deleteList(id: UUID) {
        repository.deleteList(with: id)
        shoppingLists = repository.fetchAllLists()
    }

    func deleteLists(atOffsets offsets: IndexSet) {
        offsets.map { shoppingLists[$0].id }.forEach { repository.deleteList(with: $0) }
        shoppingLists = repository.fetchAllLists()
    }

    func moveLists(fromOffsets offsets: IndexSet, toOffset offset: Int) {
        shoppingLists.move(fromOffsets: offsets, toOffset: offset)

        for (index, list) in shoppingLists.enumerated() {
            var updatedList = list
            updatedList.order = index
            repository.updateList(updatedList)
        }
    }

    func addList() {
        let newList = ShoppingList(id: UUID(), name: "New List", items: [], order: 0) // TODO: temporary empty list
        repository.addList(newList)
        shoppingLists = repository.fetchAllLists()
    }
}
