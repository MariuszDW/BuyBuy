//
//  ShoppingListViewModel.swift
//  BuyBuy
//
//  Created by MDW on 14/05/2025.
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class ShoppingListViewModel: ObservableObject {
    private let dataManager: DataManagerProtocol
    private var coordinator: (any AppCoordinatorProtocol)?
    
    lazy var remoteChangeObserver: PersistentStoreChangeObserver = {
        PersistentStoreChangeObserver(coreDataStack: dataManager.coreDataStack) { [weak self] in
            guard let self = self else { return }
            await self.loadList()
        }
    }()
    
    private let listID: UUID
    @Published var list: ShoppingList?
    @Published var thumbnails: [String: UIImage] = [:]
    
    @Published var sections: [ShoppingListSection] = [
        ShoppingListSection(status: .pending),
        ShoppingListSection(status: .purchased),
        ShoppingListSection(status: .inactive)
    ]
    
    init(listID: UUID, dataManager: DataManagerProtocol, coordinator: any AppCoordinatorProtocol) {
        self.listID = listID
        self.dataManager = dataManager
        self.coordinator = coordinator
    }
    
    func startObserving() {
        remoteChangeObserver.startObserving()
        print("ShoppingListViewModel - Started observing remote changes")
    }
    
    func stopObserving() {
        remoteChangeObserver.stopObserving()
        print("ShoppingListViewModel - Stopped observing remote changes")
    }
    
    var eventPublisher: AnyPublisher<AppEvent, Never> {
        coordinator?.eventPublisher ?? Empty().eraseToAnyPublisher()
    }
    
    func loadList(fullRefresh: Bool = false) async {
        print("ShoppingListViewModel.loadList(fullRefresh: \(fullRefresh))")
        if fullRefresh {
            await dataManager.refreshAllCloudData()
        }
        guard let newList = try? await dataManager.fetchShoppingList(with: listID) else { return }
        if newList != list {
            list = newList
        }
    }
    
    func addOrUpdateItem(_ item: ShoppingItem) async {
        try? await dataManager.addOrUpdateShoppingItem(item)
        await loadList()
    }
    
    func moveItemToDeleted(with id: UUID) async {
        try? await dataManager.moveShoppingItemToDeleted(with: id)
        await loadList()
    }
    
    func moveItem(from source: IndexSet, to destination: Int, in section: ShoppingItemStatus) async {
        guard let list = list else { return }
        
        var items = list.items(for: section)
        items.move(fromOffsets: source, toOffset: destination)
        
        let reorderedItems = reorderItems(items)

        for item in reorderedItems {
            try? await dataManager.addOrUpdateShoppingItem(item)
        }

        await loadList()
    }
    
    func back() {
        coordinator?.back()
    }
    
    func deleteItems(atOffsets offsets: IndexSet, section: ShoppingListSection) async {
        guard let items = list?.items(for: section.status) else { return }
        let idsToDelete = offsets.map { items[$0].id }
        list?.items.removeAll { idsToDelete.contains($0.id) }
        try? await dataManager.deleteShoppingItems(with: idsToDelete)
        await loadList()
    }
    
    func toggleCollapse(ofSection section: ShoppingListSection) {
        guard let index = sections.firstIndex(where: { $0.status == section.status }) else { return }
        withAnimation {
            sections[index].isCollapsed.toggle()
        }
    }
    
    func toggleStatus(for itemID: UUID) {
        guard let item = list?.item(with: itemID) else { return }
        Task {
            await setStatus(item.status.toggled(), itemID: item.id)
        }
    }
    
    func setStatus(_ status: ShoppingItemStatus, itemID: UUID) async {
        guard var currentList = self.list else { return }
        guard let oldItemIndex = currentList.items.firstIndex(where: { $0.id == itemID }) else { return }

        var updatedItem = currentList.items[oldItemIndex]
        let oldStatus = updatedItem.status

        guard oldStatus != status else { return }

        withAnimation {
            currentList.items.remove(at: oldItemIndex)
            updatedItem.status = status
            let maxOrder = currentList.items(for: status).map(\.order).max() ?? -1
            updatedItem.order = maxOrder + 1
            currentList.items.append(updatedItem)
            self.list = currentList
        }

        let newSectionItems = reorderItems(currentList.items(for: status))
        let oldSectionItems = reorderItems(currentList.items(for: oldStatus))

        for item in newSectionItems + oldSectionItems {
            try? await dataManager.addOrUpdateShoppingItem(item)
        }

        await loadList()
    }
    
    func openNewItemDetails(listID: UUID) {
        let newItemStatus: ShoppingItemStatus = .pending
        let uniqueUUID = UUID.unique(in: list?.items.map { $0.id })
        let maxOrder = list?.items.map(\.order).max() ?? 0
        
        let newItem = ShoppingItem(id: uniqueUUID, order: maxOrder + 1, listID: listID, name: "", status: newItemStatus)
        
        coordinator?.openShoppingItemDetails(newItem, isNew: true, onDismiss: nil)
    }
    
    func openItemDetails(for itemID: UUID) {
        guard let item = list?.item(with: itemID) else { return }
        coordinator?.openShoppingItemDetails(item, isNew: false, onDismiss: nil)
    }
    
    func openItemImagePreviews(for itemID: UUID, imageIndex: Int) {
        guard let item = list?.item(with: itemID), imageIndex < item.imageIDs.count else { return }
        coordinator?.openShoppingItemImage(with: item.imageIDs, index: imageIndex, onDismiss: {_ in })
    }
    
    func openLoyaltyCards() {
        coordinator?.openLoyaltyCardList()
    }
    
    func openExportListOptions() {
        guard let list = list else { return }
        coordinator?.openShoppingListExport(list, onDismiss: {_ in })
    }
    
    var hasPurchasedItems: Bool {
        list?.items.contains { $0.status == .purchased } ?? false
    }
    
    func deletePurchasedItems() async {
        let purchasedItemIDs = list?.items
            .filter { $0.status == .purchased }
            .map { $0.id } ?? []
        
        if !purchasedItemIDs.isEmpty {
            try? await dataManager.moveShoppingItemsToDeleted(with: purchasedItemIDs)
            await loadList()
        }
    }
    
    func thumbnail(for imageID: String?) -> UIImage? {
        guard let imageID, !imageID.isEmpty else { return nil }
        if let cached = thumbnails[imageID] {
            return cached
        } else {
            Task { await loadThumbnail(for: imageID) }
            return nil
        }
    }
    
    private func loadThumbnail(for imageID: String) async {
        guard thumbnails[imageID] == nil else { return }
        do {
            let image = try await dataManager.loadThumbnail(with: imageID)
            thumbnails[imageID] = image
        } catch {
            print("Failed to load thumbnail for \(imageID): \(error)")
        }
    }
    
    private func reorderItems(_ items: [ShoppingItem]) -> [ShoppingItem] {
        return items.enumerated().map { index, item -> ShoppingItem in
            var updatedItem = item
            updatedItem.order = index
            return updatedItem
        }
    }
}
