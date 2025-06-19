//
//  DeletedItemsViewModel.swift
//  BuyBuy
//
//  Created by MDW on 14/06/2025.
//

import Foundation
import SwiftUI

@MainActor
final class DeletedItemsViewModel: ObservableObject {
    private let dataManager: DataManagerProtocol
    var coordinator: any AppCoordinatorProtocol
    
    lazy var remoteChangeObserver: PersistentStoreChangeObserver = {
        PersistentStoreChangeObserver { [weak self] in
            guard let self = self else { return }
            await self.loadItems()
        }
    }()
    
    @Published var items: [ShoppingItem]?
    @Published var thumbnails: [String: UIImage] = [:]
    
    init(dataManager: DataManagerProtocol, coordinator: any AppCoordinatorProtocol) {
        self.dataManager = dataManager
        self.coordinator = coordinator
    }
    
    func startObserving() {
        remoteChangeObserver.startObserving()
        print("DeletedItemsViewModel - Started observing remote changes") // TODO: temp
    }
    
    func stopObserving() {
        remoteChangeObserver.stopObserving()
        print("DeletedItemsViewModel - Stopped observing remote changes") // TODO: temp
    }
    
    func loadItems() async {
        print("DeletedItemsViewModel - loadItems") // TODO: temp
        guard let newItems = try? await dataManager.fetchDeletedItems() else { return }
        if newItems != items {
            items = newItems
        }
    }
    
    func addOrUpdateItem(_ item: ShoppingItem) async {
        try? await dataManager.addOrUpdateItem(item)
        await loadItems()
    }
    
    func deleteItem(with id: UUID) async {
        try? await dataManager.deleteItem(with: id)
        await loadItems()
    }
    
    func deleteAllItems() async {
        let itemIDs = items?.map { $0.id } ?? []
        
        if !itemIDs.isEmpty {
            try? await dataManager.deleteItems(with: itemIDs)
            await loadItems()
        }
    }
    
    func openShoppingListSelector(for itemID: UUID) {
        coordinator.openShoppingListSelector(forDeletedItemID: itemID) { _ in }
    }
    
    func back() {
        coordinator.back()
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
            let image = try await dataManager.loadImage(baseFileName: imageID, type: .itemThumbnail)
            thumbnails[imageID] = image
        } catch {
            print("Failed to load thumbnail for \(imageID): \(error)")
        }
    }
}
