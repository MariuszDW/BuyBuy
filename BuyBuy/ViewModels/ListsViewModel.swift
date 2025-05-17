//
//  ListsViewModel.swift
//  BuyBuy
//
//  Created by MDW on 14/05/2025.
//

import Foundation
import Combine

final class ListsViewModel: ObservableObject {
    private weak var coordinator: AppCoordinatorProtocol?
    private let repository: ListsRepositoryProtocol
    
    @Published var shoppingLists: [ShoppingList]
    @Published var listBeingCreated: ShoppingList? = nil
    @Published var isAboutPresented: Bool = false

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

    func openSettings() {
        coordinator?.goToSettings()
    }
    
    func startCreatingList() {
        listBeingCreated = ShoppingList(id: uniqueListUUID(), name: "", items: [], order: nextOrder())
    }
    
    func cancelCreatingList() {
        listBeingCreated = nil
    }
    
    func confirmCreatingList() {
        guard var newList = listBeingCreated else { return }

        newList.name = newList.name.trimmingCharacters(in: .whitespaces)
        guard !newList.name.isEmpty else { return }

        repository.addList(newList)
        shoppingLists = repository.fetchAllLists()
        listBeingCreated = nil
    }
    
    func openAbout() {
        isAboutPresented = true
    }

    func closeAbout() {
        isAboutPresented = false
    }
    
    // MARK: - Private
    
    private func nextOrder() -> Int {
        (shoppingLists.map { $0.order }.max() ?? -1) + 1
    }
    
    private func uniqueListUUID() -> UUID {
        let existingUUIDs = shoppingLists.map { $0.id }
        return UUID.unique(in: existingUUIDs)
    }
}
