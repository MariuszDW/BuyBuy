//
//  DataManager.swift
//  BuyBuy
//
//  Created by MDW on 30/05/2025.
//

import Foundation
import SwiftUI

enum DataError: Error {
    case jpegConversionFailed
}

@MainActor
class DataManager: DataManagerProtocol {
    private(set) var cloud: Bool
    private(set) var coreDataStack: CoreDataStackProtocol
    private(set) var storageManager: StorageManagerProtocol
    private var repository: DataRepositoryProtocol
    private var imageCache: NSCache<NSString, UIImage> = {
        let cache = NSCache<NSString, UIImage>()
        cache.countLimit = 100
        cache.totalCostLimit = 50 * 1024 * 1024 // 50 MB
        return cache
    }()

    init(useCloud: Bool) {
        self.cloud = useCloud
        self.coreDataStack = CoreDataStack(useCloudSync: useCloud)
        self.storageManager = StorageManager()
        self.repository = DataRepository(coreDataStack: coreDataStack)
    }
    
    init(useCloud: Bool, coreDataStack: CoreDataStackProtocol, repository: DataRepositoryProtocol) {
        self.cloud = useCloud
        self.coreDataStack = coreDataStack
        self.storageManager = StorageManager()
        self.repository = repository
    }
    
    func setup(useCloud: Bool) async {
        guard self.cloud != useCloud else { return }
        cloud = useCloud
        coreDataStack = CoreDataStack(useCloudSync: useCloud)
        self.storageManager = StorageManager()
        repository = DataRepository(coreDataStack: coreDataStack)
        imageCache.removeAllObjects()
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
    
    func fetchAllItemImageIDs() async throws -> Set<String> {
        return try await repository.fetchAllItemImageIDs()
    }
    
    func fetchItemsWithMissingImages() async throws -> [ShoppingItem] {
        return try await repository.fetchItemsWithMissingImages()
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
    
    func fetchAllLoyaltyCardImageIDs() async throws -> Set<String> {
        return try await repository.fetchAllLoyaltyCardImageIDs()
    }
    
    func fetchLoyaltyCardsWithMissingImages() async throws -> [LoyaltyCard] {
        return try await repository.fetchLoyaltyCardsWithMissingImages()
    }
    
    // MARK: - Images
    
    func saveImageToTemporaryDir(_ image: UIImage, baseFileName: String) async throws {
        let thumbnail: UIImage = await image.createThumbnail() ?? UIImage()
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw DataError.jpegConversionFailed
        }
        guard let thumbnailData = thumbnail.jpegData(compressionQuality: 0.7) else {
            throw DataError.jpegConversionFailed
        }
        
        let storageManager = StorageManager()
        
        storageManager.saveData(imageData, named: baseFileName + ".jpg", to: .temporary)
        storageManager.saveData(thumbnailData, named: baseFileName + "_thumb.jpg", to: .temporary)
    }
    
    func loadImage(with baseFileName: String) async throws -> UIImage? {
        guard let imageData = try await repository.fetchImageData(id: baseFileName) else {
            return nil
        }
        return UIImage(data: imageData)
    }
    
    func loadThumbnail(with baseFileName: String) async throws -> UIImage? {
        let cacheKey = baseFileName + "_thumb" as NSString
        
        if let cachedThumbnail = imageCache.object(forKey: cacheKey) {
            return cachedThumbnail
        }
        
        guard let imageData = try await repository.fetchThumbnailData(id: baseFileName) else {
            return nil
        }
        
        guard let image = UIImage(data: imageData) else {
            return nil
        }
        
        imageCache.setObject(image, forKey: cacheKey)
        return image
    }
    
    func cleanImageCache() async {
        print("Clean image cache.")
        imageCache.removeAllObjects()
    }
    
    func cleanTemporaryImages() async {
        print("Clean temporary image files.")
        let tempFiles = storageManager.listFiles(in: .temporary, subfolders: nil)
            .filter { $0.pathExtension.lowercased() == "jpg" }
        
        for fileURL in tempFiles {
            storageManager.deleteFile(named: fileURL.lastPathComponent, in: .temporary, subfolders: nil)
        }
        print("Removed \(tempFiles.count) temporary image files.")
    }
    
    // MARK: - Files
    
    func saveFile(fileName: String, from base: StorageLocation, subfolders: [String]? = nil, data: Data) {
        storageManager.saveData(data, named: fileName, to: base, subfolders: subfolders)
    }
    
    func readFile(named fileName: String, from base: StorageLocation, subfolders: [String]? = nil) -> Data? {
        storageManager.readData(named: fileName, from: base, subfolders: subfolders)
    }
    
    func deleteFile(named fileName: String, in base: StorageLocation, subfolders: [String]? = nil) {
        storageManager.deleteFile(named: fileName, in: base, subfolders: subfolders)
    }
    
    func listFiles(in base: StorageLocation, subfolders: [String]?) /*async throws*/ -> [String] {
        let fileURLs = storageManager.listFiles(in: base, subfolders: subfolders)
        return fileURLs.map { $0.lastPathComponent }
    }
    
    // MARK: - Refresh cloud data
    
    func refreshAllCloudData() async {
        guard cloud == true else { return }
        repository.fetchRemoteChangesFromCloudKit()
    }
    
    // MARK: - Debug
    
#if DEBUG
//    func printEnvironmentPaths() async {
//        let fileManager = FileManager.default
//        
//        if let documents = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
//            print("Documents: \(documents.path)")
//        }
//        
//        if let caches = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first {
//            print("Caches: \(caches.path)")
//        }
//        
//        if let preferences = fileManager
//            .urls(for: .libraryDirectory, in: .userDomainMask)
//            .first?
//            .appendingPathComponent("Preferences")
//        {
//            print("Preferences: \(preferences.path)")
//        }
//        
//        let tmp = NSTemporaryDirectory()
//        print("tmp: \(tmp)")
//        
//        if let ubiquityURL = fileManager.url(forUbiquityContainerIdentifier: nil) {
//            print("iCloud container: \(ubiquityURL.path)")
//            print("iCloud Documents: \(ubiquityURL.appendingPathComponent("Documents").path)")
//        } else {
//            print("iCloud container is not available.")
//        }
//        
//        let itemImagesFolder = ImageStorage.directoryURL(for: .itemImage, cloud: cloud)
//        let cardImagesFolder = ImageStorage.directoryURL(for: .cardImage, cloud: cloud)
//        print("Item images folder: \(itemImagesFolder?.absoluteString ?? "error")")
//        print("Card images folder: \(cardImagesFolder?.absoluteString ?? "error")")
//    }
#endif
}
