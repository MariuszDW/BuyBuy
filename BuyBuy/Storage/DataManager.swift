//
//  DataManager.swift
//  BuyBuy
//
//  Created by MDW on 30/05/2025.
//

import Foundation
import SwiftUI

@MainActor
final class DataManager: DataManagerProtocol {
    private let repository: DataRepositoryProtocol
    private let imageStorage: ImageStorageProtocol

    init(repository: DataRepositoryProtocol,
         imageStorage: ImageStorageProtocol) {
        self.repository = repository
        self.imageStorage = imageStorage
    }
    
    // MARK: - DataRepository
    
    func fetchAllLists() async throws -> [ShoppingList] {
        return try await repository.fetchAllLists()
    }
    
    func fetchList(with id: UUID) async throws -> ShoppingList? {
        return try await repository.fetchList(with: id)
    }
    
    func addOrUpdateList(_ list: ShoppingList) async throws {
        if let oldList = try await repository.fetchList(with: list.id) {
            let oldImageIDs = Set(oldList.items.flatMap { $0.imageIDs })
            let newImageIDs = Set(list.items.flatMap { $0.imageIDs })
            let removedImageIDs = oldImageIDs.subtracting(newImageIDs)
            for id in removedImageIDs {
                try await imageStorage.deleteImageAndThumbnail(baseFileName: id, type: .item)
            }
        }
        try await repository.addOrUpdateList(list)
    }
    
    func deleteList(with id: UUID) async throws {
        let items = try await repository.fetchItemsOfList(with: id)
        let allImageIDs = items.flatMap { $0.imageIDs }
        for imageID in allImageIDs {
            try await imageStorage.deleteImageAndThumbnail(baseFileName: imageID, type: .item)
        }
        try await repository.deleteList(with: id)
    }
    
    func deleteLists(with ids: [UUID]) async throws {
        for id in ids {
            let items = try await repository.fetchItemsOfList(with: id)
            let allImageIDs = items.flatMap { $0.imageIDs }
            for imageID in allImageIDs {
                try await imageStorage.deleteImageAndThumbnail(baseFileName: imageID, type: .item)
            }
        }
        try await repository.deleteLists(with: ids)
    }

    // Shopping items
    
    func fetchItemsOfList(with listID: UUID) async throws -> [ShoppingItem] {
        return try await repository.fetchItemsOfList(with: listID)
    }
    
    func fetchItem(with id: UUID) async throws -> ShoppingItem? {
        return try await repository.fetchItem(with: id)
    }
    
    func addOrUpdateItem(_ item: ShoppingItem) async throws {
        let oldItem = try await repository.fetchItem(with: item.id)
        let oldImageIDs = oldItem?.imageIDs ?? []

        try await repository.addOrUpdateItem(item)

        let allItems = try await repository.fetchAllItems()
        let usedImageIDs = Set(allItems.flatMap { $0.imageIDs })

        let orphanedImageIDs = oldImageIDs.filter { !usedImageIDs.contains($0) }

        for id in orphanedImageIDs {
            try await imageStorage.deleteImageAndThumbnail(baseFileName: id, type: .item)
        }
    }
    
    func deleteItem(with id: UUID) async throws {
        guard let item = try await repository.fetchItem(with: id) else {
            return
        }
        let oldImageIDs = item.imageIDs

        try await repository.deleteItem(with: id)

        let allItems = try await repository.fetchAllItems()
        let usedImageIDs = Set(allItems.flatMap { $0.imageIDs })

        let orphanedImageIDs = oldImageIDs.filter { !usedImageIDs.contains($0) }

        for id in orphanedImageIDs {
            try await imageStorage.deleteImageAndThumbnail(baseFileName: id, type: .item)
        }
    }
    
    func deleteItems(with ids: [UUID]) async throws {
        let itemsToDelete = try await repository.fetchItems(with: ids)
        let oldImageIDs = itemsToDelete.flatMap { $0.imageIDs }

        try await repository.deleteItems(with: ids)

        let allItems = try await repository.fetchAllItems()
        let usedImageIDs = Set(allItems.flatMap { $0.imageIDs })

        let orphanedImageIDs = Set(oldImageIDs).subtracting(usedImageIDs)

        for id in orphanedImageIDs {
            try await imageStorage.deleteImageAndThumbnail(baseFileName: id, type: .item)
        }
    }
    
    func cleanOrphanedItems() async throws {
        try await repository.cleanOrphanedItems()
    }
    
    // MARK: - Loyalty Cards
    func fetchLoyaltyCards() async throws -> [LoyaltyCard] {
        return try await repository.fetchLoyaltyCards()
    }
    
    func fetchLoyaltyCard(with id: UUID) async throws -> LoyaltyCard? {
        return try await repository.fetchLoyaltyCard(with: id)
    }
    
    func addOrUpdateLoyaltyCard(_ card: LoyaltyCard) async throws {
        try await repository.addOrUpdateLoyaltyCard(card)
    }
    
    func deleteLoyaltyCard(with id: UUID) async throws {
        try await repository.deleteLoyaltyCard(with: id)
    }
    
    // MARK: - Images
    
    func saveImageAndThumbnail(_ image: UIImage, baseFileName: String, type: ImageType) async throws {
        try await imageStorage.saveImageAndThumbnail(image, baseFileName: baseFileName, type: type)
    }
    
    func loadImage(baseFileName: String, type: ImageType) async throws -> UIImage {
        return try await imageStorage.loadImage(baseFileName: baseFileName, type: type)
    }
    
    func loadThumbnail(baseFileName: String, type: ImageType) async throws -> UIImage {
        return try await imageStorage.loadThumbnail(baseFileName: baseFileName, type: type)
    }
    
    func deleteImageAndThumbnail(baseFileName: String, type: ImageType) async throws {
        try await imageStorage.deleteImageAndThumbnail(baseFileName: baseFileName, type: type)
    }
    
    // MARK: - Cache and cleanup
    
    func cleanThumbnailCache() async {
        await imageStorage.cleanThumbnailCache()
    }
    
    func cleanOrphanedItemImages() async throws {
        let allItemImageBaseNames = try await imageStorage.listAllImageBaseNames(type: .item)
        let usedItemImageIDs = try await repository.fetchAllItemImageIDs()
        
        let orphanedItemIDs = allItemImageBaseNames.subtracting(usedItemImageIDs)
        
        for id in orphanedItemIDs {
            try await imageStorage.deleteImageAndThumbnail(baseFileName: id, type: .item)
        }
    }
    
    func cleanOrphanedCardImages() async throws {
        let allCardImageBaseNames = try await imageStorage.listAllImageBaseNames(type: .card)
        let usedCardImageIDs = try await repository.fetchAllLoyaltyCardImageIDs()
        
        let orphanedCardIDs = allCardImageBaseNames.subtracting(usedCardImageIDs)
        
        for id in orphanedCardIDs {
            try await imageStorage.deleteImageAndThumbnail(baseFileName: id, type: .card)
        }
    }
}
