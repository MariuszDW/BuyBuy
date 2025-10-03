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
    struct ItemSection: Identifiable {
        let id = UUID()
        let deletedDate: Date
        var items: [ShoppingItem]
    }
    
    private let dataManager: DataManagerProtocol
    private weak var coordinator: (any AppCoordinatorProtocol)?
    private var observerRegistered = false

    @Published var items: [ShoppingItem]? {
        didSet { updateSections() }
    }
    @Published var sections: [ItemSection] = []
    @Published var thumbnails: [String: UIImage] = [:]
    
    init(dataManager: DataManagerProtocol, coordinator: any AppCoordinatorProtocol) {
        self.dataManager = dataManager
        self.coordinator = coordinator
    }
    
    func startObserving() {
        guard !observerRegistered else { return }
        dataManager.persistentStoreChangeObserver.addObserver(self) { [weak self] in
            Task { await self?.loadItems() }
        }
        observerRegistered = true
        AppLogger.general.debug("DeletedItemsViewModel - Started observing remote changes")
    }
    
    func stopObserving() {
        guard observerRegistered else { return }
        dataManager.persistentStoreChangeObserver.removeObserver(self)
        observerRegistered = false
        AppLogger.general.debug("DeletedItemsViewModel - Stopped observing remote changes")
    }
    
    func loadItems(fullRefresh: Bool = false) async {
        AppLogger.general.debug("DeletedItemsViewModel.loadItems(fullRefresh: \(fullRefresh, privacy: .public))")
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
        guard !itemIDs.isEmpty else { return }
        try? await dataManager.deleteShoppingItems(with: itemIDs)
        await loadItems()
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

    private func updateSections() {
        guard let items else {
            sections = []
            return
        }
        let calendar = Calendar.current
        
        var dict: [Date: [ShoppingItem]] = [:]
        for item in items {
            let deletedAt = item.deletedAt ?? Date()
            let dayStart = calendar.startOfDay(for: deletedAt)
            dict[dayStart, default: []].append(item)
        }

        sections = dict
            .map { ItemSection(deletedDate: $0.key, items: $0.value) }
            .sorted { $0.deletedDate > $1.deletedDate }
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
}
