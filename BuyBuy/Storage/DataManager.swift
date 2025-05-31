//
//  DataManager.swift
//  BuyBuy
//
//  Created by MDW on 30/05/2025.
//

import Foundation
import UIKit

@MainActor
final class DataManager: DataManagerProtocol {
    private let repository: ShoppingListsRepositoryProtocol
    private let imageStorage: ImageStorageProtocol

    init(repository: ShoppingListsRepositoryProtocol,
         imageStorage: ImageStorageProtocol) {
        self.repository = repository
        self.imageStorage = imageStorage
    }
    
    // MARK: - ShoppingListsRepository
    
    // Shopping lists
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
                try await imageStorage.deleteImage(baseFileName: id)
                try await imageStorage.deleteThumbnail(baseFileName: id)
            }
        }
        try await repository.addOrUpdateList(list)
    }
    
    func deleteList(with id: UUID) async throws {
        let items = try await repository.fetchItemsOfList(with: id)
        let allImageIDs = items.flatMap { $0.imageIDs }
        for imageID in allImageIDs {
            try await imageStorage.deleteImage(baseFileName: imageID)
            try await imageStorage.deleteThumbnail(baseFileName: imageID)
        }
        try await repository.deleteList(with: id)
    }
    
    func deleteLists(with ids: [UUID]) async throws {
        for id in ids {
            let items = try await repository.fetchItemsOfList(with: id)
            let allImageIDs = items.flatMap { $0.imageIDs }
            for imageID in allImageIDs {
                try await imageStorage.deleteImage(baseFileName: imageID)
                try await imageStorage.deleteThumbnail(baseFileName: imageID)
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
            try await imageStorage.deleteImage(baseFileName: id)
            try await imageStorage.deleteThumbnail(baseFileName: id)
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
            try await imageStorage.deleteImage(baseFileName: id)
            try await imageStorage.deleteThumbnail(baseFileName: id)
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
            try await imageStorage.deleteImage(baseFileName: id)
            try await imageStorage.deleteThumbnail(baseFileName: id)
        }
    }
    
    // Data cleaning
    func cleanOrphanedItems() async throws {
        try await repository.cleanOrphanedItems()
    }
    
    // MARK: - ImageStorage
    
    func saveImage(_ image: UIImage, baseFileName: String) async throws {
        try await imageStorage.saveImage(image, baseFileName: baseFileName)
    }
    
    func saveThumbnail(for image: UIImage, baseFileName: String) async throws {
        try await imageStorage.saveThumbnail(for: image, baseFileName: baseFileName)
    }
    
    func loadImage(baseFileName: String) async throws -> UIImage {
        return try await imageStorage.loadImage(baseFileName: baseFileName)
    }
    
    func loadThumbnail(baseFileName: String) async throws -> UIImage {
        return try await imageStorage.loadThumbnail(baseFileName: baseFileName)
    }
    
    func deleteImage(baseFileName: String) async throws {
        try await imageStorage.deleteImage(baseFileName: baseFileName)
    }
    
    func deleteThumbnail(baseFileName: String) async throws {
        try await imageStorage.deleteThumbnail(baseFileName: baseFileName)
    }
    
    func clearThumbnailCache() async {
        await imageStorage.clearThumbnailCache()
    }
}
