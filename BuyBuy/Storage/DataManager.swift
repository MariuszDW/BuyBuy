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
    private var cloud: Bool
    private var coreDataStack: CoreDataStackProtocol
    var imageStorage: ImageStorageProtocol
    private var fileStorage: FileStorageProtocol
    private var repository: DataRepositoryProtocol

    init(useCloud: Bool) {
        self.cloud = useCloud
        self.coreDataStack = CoreDataStack(useCloudSync: useCloud)
        self.imageStorage = ImageStorage(useCloudSync: useCloud)
        self.fileStorage = FileStorage()
        self.repository = DataRepository(coreDataStack: coreDataStack)
    }
    
    init(useCloud: Bool, coreDataStack: CoreDataStackProtocol, imageStorage: ImageStorageProtocol, fileStorage: FileStorageProtocol, repository: DataRepositoryProtocol) {
        self.cloud = useCloud
        self.coreDataStack = coreDataStack
        self.imageStorage = imageStorage
        self.fileStorage = fileStorage
        self.repository = repository
    }
    
    func setup(useCloud: Bool) async {
        guard self.cloud != useCloud else { return }
        cloud = useCloud
        coreDataStack = CoreDataStack(useCloudSync: useCloud)
        imageStorage = ImageStorage(useCloudSync: useCloud)
        fileStorage = FileStorage()
        repository = DataRepository(coreDataStack: coreDataStack)
        if useCloud {
            try? await imageStorage.forceDownloadImages(type: .itemImage, onlyHiddenFiles: true)
            try? await imageStorage.forceDownloadImages(type: .cardImage, onlyHiddenFiles: true)
        }
    }
    
    // MARK: - Shopping lists
    
    func fetchAllLists() async throws -> [ShoppingList] {
        return try await repository.fetchAllLists()
    }
    
    func fetchList(with id: UUID) async throws -> ShoppingList? {
        return try await repository.fetchList(with: id)
    }
    
    func addOrUpdateList(_ list: ShoppingList) async throws {
        try await repository.addOrUpdateList(list)
    }
    
    func deleteList(with id: UUID, moveItemsToDeleted: Bool) async throws {
        let items = try await repository.fetchItemsOfList(with: id)
        
        if moveItemsToDeleted {
            for var item in items {
                item.moveToDeleted()
                try await repository.addOrUpdateItem(item)
            }
        }
        
        try await repository.deleteList(with: id)
    }

    func deleteLists(with ids: [UUID], moveItemsToDeleted: Bool) async throws {
        for id in ids {
            let items = try await repository.fetchItemsOfList(with: id)

            if moveItemsToDeleted {
                for var item in items {
                    item.moveToDeleted()
                    try await repository.addOrUpdateItem(item)
                }
            }
        }
        
        try await repository.deleteLists(with: ids)
    }

    func deleteAllLists() async throws {
        try await repository.deleteAllLists()
    }

    // MARK: - Shopping items
    
    func fetchAllItems() async throws -> [ShoppingItem]  {
        return try await repository.fetchAllItems()
    }
    
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
        try await repository.addOrUpdateItem(item)
    }
    
    func moveItemToDeleted(with id: UUID) async throws {
        guard var item = try await repository.fetchItem(with: id) else {
            return
        }
        item.moveToDeleted()
        try await repository.addOrUpdateItem(item)
    }
    
    func moveItemsToDeleted(with ids: [UUID]) async throws {
        var items = try await repository.fetchItems(with: ids)
        guard !items.isEmpty else { return }
        for i in items.indices {
            items[i].moveToDeleted()
            try await repository.addOrUpdateItem(items[i])
        }
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
        print("DataManager.deleteOldTrashedItems(olderThan: \(days))")
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
        try await repository.deleteItem(with: id)
    }
    
    func deleteItems(with ids: [UUID]) async throws {
        try await repository.deleteItems(with: ids)
    }
    
    func deleteAllItems() async throws {
        try await repository.deleteAllItems()
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
        try await repository.addOrUpdateLoyaltyCard(card)
    }
    
    func deleteLoyaltyCard(with id: UUID) async throws {
        try await repository.deleteLoyaltyCard(with: id)
    }
    
    func deleteAllLoyaltyCards() async throws {
        try await repository.deleteAllLoyaltyCards()
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
    
    func loadImage(baseFileName: String, type: ImageType) async throws -> UIImage? {
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
    
    // MARK: - Refresh cloud data
    
    func refreshAllCloudData() async {
        guard cloud == true else { return }
        repository.fetchRemoteChangesFromCloudKit()
        try? await imageStorage.forceDownloadImages(type: .itemImage, onlyHiddenFiles: false)
        try? await imageStorage.forceDownloadImages(type: .cardImage, onlyHiddenFiles: false)
    }
    
    // MARK: - Debug
    
#if DEBUG
    func printEnvironmentPaths() async {
        let fileManager = FileManager.default
        
        if let documents = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            print("Documents: \(documents.path)")
        }
        
        if let caches = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first {
            print("Caches: \(caches.path)")
        }
        
        if let preferences = fileManager
            .urls(for: .libraryDirectory, in: .userDomainMask)
            .first?
            .appendingPathComponent("Preferences")
        {
            print("Preferences: \(preferences.path)")
        }
        
        let tmp = NSTemporaryDirectory()
        print("tmp: \(tmp)")
        
        if let ubiquityURL = fileManager.url(forUbiquityContainerIdentifier: nil) {
            print("iCloud container: \(ubiquityURL.path)")
            print("iCloud Documents: \(ubiquityURL.appendingPathComponent("Documents").path)")
        } else {
            print("iCloud container is not available.")
        }
        
        let itemImagesFolder = await imageStorage.directoryURL(for: .itemImage)
        let cardImagesFolder = await imageStorage.directoryURL(for: .cardImage)
        print("Item images folder: \(itemImagesFolder?.absoluteString ?? "error")")
        print("Card images folder: \(cardImagesFolder?.absoluteString ?? "error")")
    }
    
    func printListOfImages() async {
        let itemImages = try? await imageStorage.listImageBaseNames(type: .itemImage)
        let cardImages = try? await imageStorage.listImageBaseNames(type: .cardImage)
        print("List of item images:")
        itemImages?.forEach { print(" •", $0) }
        print("List of card images:")
        cardImages?.forEach { print(" •", $0) }
    }
#endif
}
