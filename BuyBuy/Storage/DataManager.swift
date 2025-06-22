//
//  DataManager.swift
//  BuyBuy
//
//  Created by MDW on 30/05/2025.
//

import Foundation
import SwiftUI

@MainActor
class DataManager: DataManagerProtocol {
    private let repository: DataRepositoryProtocol
    private let imageStorage: ImageStorageProtocol
    private let fileStorage: FileStorageProtocol

    init(repository: DataRepositoryProtocol,
         imageStorage: ImageStorageProtocol,
         fileStorage: FileStorageProtocol) {
        self.repository = repository
        self.imageStorage = imageStorage
        self.fileStorage = fileStorage
    }
    
    // MARK: - Shopping lists
    
    func fetchAllLists() async throws -> [ShoppingList] {
        return try await repository.fetchAllLists()
    }
    
    func fetchList(with id: UUID) async throws -> ShoppingList? {
        return try await repository.fetchList(with: id)
    }
    
    func addOrUpdateList(_ list: ShoppingList) async throws {
//        if let oldList = try await repository.fetchList(with: list.id) {
//            let oldImageIDs = Set(oldList.items.flatMap { $0.imageIDs })
//            let newImageIDs = Set(list.items.flatMap { $0.imageIDs })
//            let removedImageIDs = oldImageIDs.subtracting(newImageIDs)
//            for id in removedImageIDs {
//                try await imageStorage.deleteImage(baseFileName: id, types: [.itemImage, .itemThumbnail])
//            }
//        }
        // Images of the list items will be deleted by cleanOrphanedItemImages() in performStartupTasks().
        try await repository.addOrUpdateList(list)
    }
    
    func deleteList(with id: UUID, moveItemsToDeleted: Bool) async throws {
        let items = try await repository.fetchItemsOfList(with: id)
//        let allImageIDs = items.flatMap { $0.imageIDs }
        
        if moveItemsToDeleted {
            for var item in items {
                item.moveToDeleted()
                try await repository.addOrUpdateItem(item)
            }
        }
        
        // The list item images will be deleted by cleanOrphanedItemImages() in performStartupTasks().

        try await repository.deleteList(with: id)
        
//        if !moveItemsToDeleted {
//            for imageID in allImageIDs {
//                try await imageStorage.deleteImage(baseFileName: imageID, types: [.itemImage, .itemThumbnail])
//            }
//        }
    }

    func deleteLists(with ids: [UUID], moveItemsToDeleted: Bool) async throws {
//        var allImageIDs = [String]()

        for id in ids {
            let items = try await repository.fetchItemsOfList(with: id)

            if moveItemsToDeleted {
                for var item in items {
                    item.moveToDeleted()
                    try await repository.addOrUpdateItem(item)
                }
            }
//            else {
//                allImageIDs.append(contentsOf: items.flatMap { $0.imageIDs })
//            }
        }
        
        // The lists item images will be deleted by cleanOrphanedItemImages() in performStartupTasks().

        try await repository.deleteLists(with: ids)

//        if !moveItemsToDeleted {
//            for imageID in allImageIDs {
//                try await imageStorage.deleteImage(baseFileName: imageID, types: [.itemImage, .itemThumbnail])
//            }
//        }
    }


    // MARK: - Shopping items
    
    func fetchItemsOfList(with listID: UUID) async throws -> [ShoppingItem] {
        return try await repository.fetchItemsOfList(with: listID)
    }
    
    func fetchItem(with id: UUID) async throws -> ShoppingItem? {
        return try await repository.fetchItem(with: id)
    }
    
    func fetchDeletedItems() async throws -> [ShoppingItem] {
        return try await repository.fetchDeletedItems()
    }
    
    func addOrUpdateItem(_ item: ShoppingItem) async throws {
//        let oldItem = try await repository.fetchItem(with: item.id)
//        let oldImageIDs = oldItem?.imageIDs ?? []
        
        // The item images will be deleted by cleanOrphanedItemImages() in performStartupTasks().
        try await repository.addOrUpdateItem(item)

//        let usedImageIDs = try await repository.fetchAllItemImageIDs()
//        let orphanedImageIDs = oldImageIDs.filter { !usedImageIDs.contains($0) }
//        for id in orphanedImageIDs {
//            try await imageStorage.deleteImage(baseFileName: id, types: [.itemImage, .itemThumbnail])
//        }
    }
    
    func moveItemToDeleted(with id: UUID) async throws {
        guard var item = try await repository.fetchItem(with: id) else {
            return
        }
        item.moveToDeleted()
        try await repository.addOrUpdateItem(item)
    }
    
    func restoreItem(with id: UUID, toList listID: UUID) async throws {
        guard let _ = try await repository.fetchList(with: listID) else {
            throw NSError(domain: "Repository", code: 404, userInfo: [NSLocalizedDescriptionKey: "List not found"])
        }
        guard var item = try await repository.fetchItem(with: id) else {
            return
        }
        let maxOrder = try await repository.fetchMaxOrderOfItems(inList: listID)
        item.moveToShoppingList(with: listID, order: maxOrder + 1)
        try await repository.addOrUpdateItem(item)
    }
    
    func deleteOldTrashedItems(olderThan days: Int) async throws {
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -days, to: Date())!
        
        let trashedItems = try await repository.fetchDeletedItems()
        let oldItems = trashedItems.filter { item in
            if let deletedAt = item.deletedAt {
                return deletedAt < cutoffDate
            }
            return false
        }
        
        let idsToDelete = oldItems.map { $0.id }
        try await deleteItems(with: idsToDelete)
    }
    
    func deleteItem(with id: UUID) async throws {
//        guard let item = try await repository.fetchItem(with: id) else {
//            return
//        }
//        let oldImageIDs = item.imageIDs

        // The item images will be deleted by cleanOrphanedItemImages() in performStartupTasks().
        try await repository.deleteItem(with: id)

//        let usedImageIDs = try await repository.fetchAllItemImageIDs()
//        let orphanedImageIDs = oldImageIDs.filter { !usedImageIDs.contains($0) }
//        for id in orphanedImageIDs {
//            try await imageStorage.deleteImage(baseFileName: id, types: [.itemImage, .itemThumbnail])
//        }
    }
    
    func deleteItems(with ids: [UUID]) async throws {
//        let itemsToDelete = try await repository.fetchItems(with: ids)
//        let oldImageIDs = itemsToDelete.flatMap { $0.imageIDs }

        // Images of these items will be deleted by cleanOrphanedItemImages() in performStartupTasks().
        try await repository.deleteItems(with: ids)

//        let usedImageIDs = try await repository.fetchAllItemImageIDs()
//        let orphanedImageIDs = Set(oldImageIDs).subtracting(usedImageIDs)
//        for id in orphanedImageIDs {
//            try await imageStorage.deleteImage(baseFileName: id, types: [.itemImage, .itemThumbnail])
//        }
    }
    
    func cleanOrphanedItems() async throws {
        print("DataManager.cleanOrphanedItems()")
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
//        let oldCard = try await repository.fetchLoyaltyCard(with: card.id)
        //let oldImageID = oldCard?.imageID
        try await repository.addOrUpdateLoyaltyCard(card)
        // Image of the card will be deleted by cleanOrphanedCardImages() in performStartupTasks().
//        if let oldImageID = oldImageID {
//            let usedImageIDs = try await repository.fetchAllLoyaltyCardImageIDs()
//            if !usedImageIDs.contains(where: { $0 == oldImageID }) {
//                try await imageStorage.deleteImage(baseFileName: oldImageID, types: [.cardImage, .cardThumbnail])
//            }
//        }
    }
    
    func deleteLoyaltyCard(with id: UUID) async throws {
//        guard let card = try await repository.fetchLoyaltyCard(with: id) else { return }
//        let cardImageID = card.imageID
        try await repository.deleteLoyaltyCard(with: id)
        // Image of the card will be deleted by cleanOrphanedCardImages() in performStartupTasks().
//        if let cardImageID = cardImageID {
//            try await imageStorage.deleteImage(baseFileName: cardImageID, types: [.cardImage, .cardThumbnail])
//        }
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
        print("DataManager.cleanOrphanedItemImages()")
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
        print("DataManager.cleanOrphanedCardImages()")
        let cardImageBaseNames = try await imageStorage.listImageBaseNames(type: .cardImage)
        let cardThumbnailBaseNames = try await imageStorage.listImageBaseNames(type: .cardThumbnail)
        let allBaseNames: Set<String> = cardImageBaseNames.union(cardThumbnailBaseNames)
        
        let usedCardImageIDs = try await repository.fetchAllLoyaltyCardImageIDs()
        let orphanedCardIDs = allBaseNames.subtracting(usedCardImageIDs)
        
        for id in orphanedCardIDs {
            try await imageStorage.deleteImage(baseFileName: id, types: [.cardImage, .cardThumbnail])
        }
    }
    
    // MARK: - Files
    
    func saveFile(data: Data, fileName: String) async throws {
        try await fileStorage.saveFile(data: data, fileName: fileName)
    }
    
    func readFile(fileName: String) async throws -> Data {
        return try await fileStorage.readFile(fileName: fileName)
    }
    
    func deleteFile(fileName: String) async throws {
        try await fileStorage.deleteFile(fileName: fileName)
    }
    
    func listFiles() async throws -> [String] {
        return try await fileStorage.listFiles()
    }
}
