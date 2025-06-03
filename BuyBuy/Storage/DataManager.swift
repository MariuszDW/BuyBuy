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
    
    // MARK: - Shopping lists
    
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
                try await imageStorage.deleteImage(baseFileName: id, types: [.itemImage, .itemThumbnail])
            }
        }
        try await repository.addOrUpdateList(list)
    }
    
    func deleteList(with id: UUID) async throws {
        let items = try await repository.fetchItemsOfList(with: id)
        let allImageIDs = items.flatMap { $0.imageIDs }
        for imageID in allImageIDs {
            try await imageStorage.deleteImage(baseFileName: imageID, types: [.itemImage, .itemThumbnail])
        }
        try await repository.deleteList(with: id)
    }
    
    func deleteLists(with ids: [UUID]) async throws {
        for id in ids {
            let items = try await repository.fetchItemsOfList(with: id)
            let allImageIDs = items.flatMap { $0.imageIDs }
            for imageID in allImageIDs {
                try await imageStorage.deleteImage(baseFileName: imageID, types: [.itemImage, .itemThumbnail])
            }
        }
        try await repository.deleteLists(with: ids)
    }

    // MARK: - Shopping items
    
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
            try await imageStorage.deleteImage(baseFileName: id, types: [.itemImage, .itemThumbnail])
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
            try await imageStorage.deleteImage(baseFileName: id, types: [.itemImage, .itemThumbnail])
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
            try await imageStorage.deleteImage(baseFileName: id, types: [.itemImage, .itemThumbnail])
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
    
    func saveImage(_ image: UIImage, baseFileName: String, type: ImageType) async throws {
        try await imageStorage.saveImage(image, baseFileName: baseFileName, type: type)
    }
    
    func saveImage(_ image: UIImage, baseFileName: String, types: [ImageType]) async throws {
        for type in types {
            try await imageStorage.saveImage(image, baseFileName: baseFileName, type: type)
        }
    }
    
    func loadImage(baseFileName: String, type: ImageType) async throws -> UIImage {
        return try await imageStorage.loadImage(baseFileName: baseFileName, type: type)
    }
    
    func deleteImage(baseFileName: String, type: ImageType) async throws {
        try await imageStorage.deleteImage(baseFileName: baseFileName, type: type)
    }
    
    func deleteImage(baseFileName: String, types: [ImageType]) async throws {
        for type in types {
            try await imageStorage.deleteImage(baseFileName: baseFileName, type: type)
        }
    }
    
    // MARK: - Image cache
    
    func cleanImageCache() async {
        await imageStorage.cleanCache()
    }
    
    func cleanOrphanedItemImages() async throws {
        let itemImageBaseNames = try await imageStorage.listImageBaseNames(type: .itemImage)
        let itemThumbnailBaseNames = try await imageStorage.listImageBaseNames(type: .itemThumbnail)
        let allBaseNames: Set<String> = itemImageBaseNames.union(itemThumbnailBaseNames)
        
        let usedItemImageIDs = try await repository.fetchAllItemImageIDs()
        
        let orphanedItemIDs = allBaseNames.subtracting(usedItemImageIDs)
        
        for id in orphanedItemIDs {
            try await imageStorage.deleteImage(baseFileName: id, types: [.itemImage, .itemThumbnail])
        }
    }
    
    func cleanOrphanedCardImages() async throws {
        let cardImageBaseNames = try await imageStorage.listImageBaseNames(type: .cardImage)
        let cardThumbnailBaseNames = try await imageStorage.listImageBaseNames(type: .cardThumbnail)
        let allBaseNames: Set<String> = cardImageBaseNames.union(cardThumbnailBaseNames)
        
        let usedCardImageIDs = try await repository.fetchAllLoyaltyCardImageIDs()
        
        let orphanedCardIDs = allBaseNames.subtracting(usedCardImageIDs)
        
        for id in orphanedCardIDs {
            try await imageStorage.deleteImage(baseFileName: id, types: [.cardImage, .cardThumbnail])
        }
    }
}
