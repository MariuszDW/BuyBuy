//
//  DeletedItemsViewModel.swift
//  BuyBuy
//
//  Created by MDW on 14/06/2025.
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class DeletedItemsViewModel: ObservableObject {
    private let dataManager: DataManagerProtocol
    private weak var coordinator: (any AppCoordinatorProtocol)?
    
    lazy var remoteChangeObserver: PersistentStoreChangeObserver = {
        PersistentStoreChangeObserver(coreDataStack: dataManager.coreDataStack) { [weak self] in
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
        print("DeletedItemsViewModel - Started observing remote changes")
    }
    
    func stopObserving() {
        remoteChangeObserver.stopObserving()
        print("DeletedItemsViewModel - Stopped observing remote changes")
    }
    
    func loadItems(fullRefresh: Bool = false) async {
        print("DeletedItemsViewModel.loadItems(fullRefresh: \(fullRefresh))")
        if fullRefresh {
            await dataManager.refreshAllCloudData()
        }
        guard let newItems = try? await dataManager.fetchDeletedShoppingItems() else { return }
        if newItems != items {
            items = newItems
        }
    }
    
    func addOrUpdateItem(_ item: ShoppingItem) async {
        try? await dataManager.addOrUpdateShoppingItem(item)
        await loadItems()
    }
    
    func deleteItem(with id: UUID) async {
        try? await dataManager.deleteShoppingItem(with: id)
        await loadItems()
    }
    
    func deleteAllItems() async {
        let itemIDs = items?.map { $0.id } ?? []
        
        if !itemIDs.isEmpty {
            try? await dataManager.deleteShoppingItems(with: itemIDs)
            await loadItems()
        }
    }
    
    func openShoppingListSelector(for itemID: UUID) {
        coordinator?.openShoppingListSelector(forDeletedItemID: itemID) { _ in }
    }
    
    func back() {
        coordinator?.back()
    }
    
    var eventPublisher: AnyPublisher<AppEvent, Never> {
        coordinator?.eventPublisher ?? Empty().eraseToAnyPublisher()
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
}
