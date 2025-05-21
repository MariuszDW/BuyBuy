//
//  ShoppingListsViewModel.swift
//  BuyBuy
//
//  Created by MDW on 14/05/2025.
//

import Foundation
import Combine

@MainActor
class ShoppingListsViewModel: ObservableObject {
    @Published var shoppingLists: [ShoppingList] = []

    private let repository: ShoppingListsRepositoryProtocol
    private let coordinator: any AppCoordinatorProtocol

    init(coordinator: any AppCoordinatorProtocol, repository: ShoppingListsRepositoryProtocol) {
        self.coordinator = coordinator
        self.repository = repository
    }
    
    func loadLists() async {
        let fetchedLists = try? await repository.fetchAllLists()
        self.shoppingLists = fetchedLists ?? []
    }

    func deleteLists(atOffsets offsets: IndexSet) async {
        let idsToDelete = offsets.map { shoppingLists[$0].id }
        shoppingLists.removeAll { idsToDelete.contains($0.id) }
        try? await repository.deleteLists(ids: idsToDelete)
        await loadLists()
    }

    func deleteList(id: UUID) async {
        shoppingLists.removeAll { $0.id == id }
        try? await repository.deleteList(id: id)
        await loadLists()
    }

    func moveLists(fromOffsets source: IndexSet, toOffset destination: Int) async {
        shoppingLists.move(fromOffsets: source, toOffset: destination)
        for index in shoppingLists.indices {
            shoppingLists[index].order = index
            try? await repository.updateList(shoppingLists[index])
        }
    }

    func startCreatingList() {
        let uniqueUUID = UUID.unique(in: shoppingLists.map { $0.id })
        let newList = ShoppingList(
            id: uniqueUUID,
            name: "",
            items: [],
            order: shoppingLists.count,
            icon: .default,
            color: .default
        )
        
        coordinator.openListSettings(newList, isNew: true, onSave: { [weak self] in
            Task {
                await self?.loadLists()
            }
        })
    }
    
    func startEditingList(_ list: ShoppingList) {
        coordinator.openListSettings(list, isNew: false, onSave: { [weak self] in
            Task {
                await self?.loadLists()
            }
        })
    }

    func openAbout() {
        coordinator.openAbout()
    }

    func openSettings() {
        coordinator.openSettings()
    }
}
