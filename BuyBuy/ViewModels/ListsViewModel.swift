//
//  ListsViewModel.swift
//  BuyBuy
//
//  Created by MDW on 14/05/2025.
//

import Foundation
import Combine

class ListsViewModel: ObservableObject {
    @Published var shoppingLists: [ShoppingList] = []

    private let repository: ListsRepositoryProtocol
    private let coordinator: any AppCoordinatorProtocol
    private var cancellables = Set<AnyCancellable>()

    init(coordinator: any AppCoordinatorProtocol, repository: ListsRepositoryProtocol) {
        self.coordinator = coordinator
        self.repository = repository
        
        coordinator.needRefreshListsPublisher
            .filter { $0 == true }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                if self?.coordinator.needRefreshLists == true {
                    self?.loadLists()
                    self?.coordinator.setNeedRefreshLists(false)
                }
            }
            .store(in: &cancellables)
    }

    func loadLists() {
        shoppingLists = repository.fetchAllLists().sorted { $0.order < $1.order }
    }

    func deleteLists(atOffsets offsets: IndexSet) {
        let idsToDelete = offsets.map { shoppingLists[$0].id }
        idsToDelete.forEach { repository.deleteList(with: $0) }
        shoppingLists.remove(atOffsets: offsets)
        updateOrders()
    }

    func deleteList(id: UUID) {
        repository.deleteList(with: id)
        shoppingLists.removeAll { $0.id == id }
        updateOrders()
    }

    func moveLists(fromOffsets source: IndexSet, toOffset destination: Int) {
        shoppingLists.move(fromOffsets: source, toOffset: destination)
        updateOrders()
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
        coordinator.openListSettings(newList, isNew: true)
    }

    func startEditingList(_ list: ShoppingList) {
        coordinator.openListSettings(list, isNew: false)
    }

    func openAbout() {
        coordinator.openAbout()
    }

    func openSettings() {
        coordinator.openSettings()
    }

    // MARK: - Helpers

    private func updateOrders() {
        for index in shoppingLists.indices {
            shoppingLists[index].order = index
            repository.updateList(shoppingLists[index])
        }
    }
}
