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
    private var observerRegistered = false
    private let listID: UUID
    
    @Published var list: ShoppingList?
    @Published var thumbnails: [String: UIImage] = [:]
    @Published private var temporaryStatuses: [UUID: ShoppingItemStatus] = [:]
    
    init(listID: UUID, dataManager: DataManagerProtocol, coordinator: any AppCoordinatorProtocol) {
        self.listID = listID
        self.dataManager = dataManager
        self.coordinator = coordinator
    }
    
    func startObserving() {
        guard !observerRegistered else { return }
        dataManager.persistentStoreChangeObserver.addObserver(self) { [weak self] in
            guard let self else { return }
            await self.loadList()
        }
        observerRegistered = true
        AppLogger.general.debug("ShoppingListViewModel - Started observing remote changes")
    }
    
    func stopObserving() {
        guard observerRegistered else { return }
        dataManager.persistentStoreChangeObserver.removeObserver(self)
        observerRegistered = false
        AppLogger.general.debug("ShoppingListViewModel - Stopped observing remote changes")
    }
    
    var eventPublisher: AnyPublisher<AppEvent, Never> {
        coordinator?.eventPublisher ?? Empty().eraseToAnyPublisher()
    }
    
    func itemCount(for itemStatus: ShoppingItemStatus? = nil) -> Int {
        guard let list = list else {
            return 0
        }
        return list.itemCount(for: itemStatus)
    }
    
    func items(for itemStatus: ShoppingItemStatus? = nil) -> [ShoppingItem] {
        guard let list = list else {
            return []
        }
        guard let itemStatus = itemStatus else {
            return list.items
        }
        return list.items(for: itemStatus)
    }
    
    func loadList(fullRefresh: Bool = false) async {
        AppLogger.general.debug("ShoppingListViewModel.loadList(fullRefresh: \(fullRefresh, privacy: .public))")
        if fullRefresh {
            await dataManager.refreshAllCloudData()
        }
        guard let newList = try? await dataManager.fetchShoppingList(with: listID) else {
            list = nil
            await MainActor.run {
                coordinator?.back()
            }
            return
        }
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
    
    func moveItem(from source: IndexSet, to destination: Int, in status: ShoppingItemStatus) async {
        guard let list = list else { return }
        
        var items = list.items(for: status)
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
    
    func deleteItems(atOffsets offsets: IndexSet, status: ShoppingItemStatus) async {
        guard let items = list?.items(for: status) else { return }
        let idsToDelete = offsets.map { items[$0].id }
        list?.items.removeAll { idsToDelete.contains($0.id) }
        try? await dataManager.deleteShoppingItems(with: idsToDelete)
        await loadList()
    }
    
    func visibleStatus(for item: ShoppingItem) -> ShoppingItemStatus {
        temporaryStatuses[item.id] ?? item.status
    }
    
    func setStatus(_ status: ShoppingItemStatus, itemID: UUID, delay: Double = 0) {
        guard var updatedItem = list?.item(with: itemID), updatedItem.status != status else {
            return
        }
        
        temporaryStatuses[updatedItem.id] = status
        
        Task {
            try? await Task.sleep(for: .seconds(delay))
        
            let maxOrder = list?.items(for: status).map(\.order).max() ?? -1
            updatedItem.status = status
            updatedItem.order = maxOrder + 1
            
            try? await dataManager.addOrUpdateShoppingItem(updatedItem)
            
            try? await Task.sleep(for: .seconds(0.3))
            
            await MainActor.run {
                self.temporaryStatuses[itemID] = nil
            }
        }
    }
    
    func openNewItemDetails(listID: UUID, itemStatus: ShoppingItemStatus) {
        let uniqueUUID = UUID.unique(in: list?.items.map { $0.id })
        let maxOrder = list?.items.map(\.order).max() ?? 0
        
        let newItem = ShoppingItem(id: uniqueUUID, order: maxOrder + 1, listID: listID, name: "", status: itemStatus)
        
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
    
    func openShareManagement() {
        guard let list = list else { return }
        Task {
            await coordinator?.openShoppingListShareManagement(with: list.id, title: list.name, onDismiss: {_ in })
        }
    }
    
    func openListSettings() {
        guard let list = list else { return }
        coordinator?.openShoppingListSettings(list, isNew: false, onDismiss: {_ in })
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
            AppLogger.general.error("Failed to load thumbnail for \(imageID, privacy: .public): \(error, privacy: .public)")
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
