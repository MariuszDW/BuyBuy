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
    
    func fetchShoppingLists() async throws -> [ShoppingList] {
        return try await repository.fetchShoppingLists()
    }
    
    func fetchShoppingList(with id: UUID) async throws -> ShoppingList? {
        return try await repository.fetchShoppingList(with: id)
    }
    
    func addOrUpdateShoppingList(_ list: ShoppingList) async throws {
        try await repository.addOrUpdateShoppingList(list)
    }
    
    func deleteShoppingList(with id: UUID, moveItemsToDeleted: Bool) async throws {
        let items = try await repository.fetchShoppingItemsOfList(with: id)
        
        if moveItemsToDeleted {
            for var item in items {
                item.moveToDeleted()
                try await repository.addOrUpdateShoppingItem(item)
            }
        }
        
        try await repository.deleteShoppingList(with: id)
    }

    func deleteShoppingLists(with ids: [UUID], moveItemsToDeleted: Bool) async throws {
        for id in ids {
            let items = try await repository.fetchShoppingItemsOfList(with: id)

            if moveItemsToDeleted {
                for var item in items {
                    item.moveToDeleted()
                    try await repository.addOrUpdateShoppingItem(item)
                }
            }
        }
        
        try await repository.deleteShoppingLists(with: ids)
    }

    func deleteShoppingLists() async throws {
        try await repository.deleteShoppingLists()
    }

    // MARK: - Shopping items
    
    func fetchShoppingItems() async throws -> [ShoppingItem]  {
        return try await repository.fetchShoppingItems()
    }
    
    func fetchShoppingItemsOfList(with listID: UUID) async throws -> [ShoppingItem] {
        return try await repository.fetchShoppingItemsOfList(with: listID)
    }
    
    func fetchShoppingItem(with id: UUID) async throws -> ShoppingItem? {
        return try await repository.fetchShoppingItem(with: id)
    }
    
    func fetchDeletedShoppingItems() async throws -> [ShoppingItem] {
        return try await repository.fetchDeletedShoppingItems()
    }
    
    func addOrUpdateShoppingItem(_ item: ShoppingItem) async throws {
        try await repository.addOrUpdateShoppingItem(item)
    }
    
    func moveShoppingItemToDeleted(with id: UUID) async throws {
        guard var item = try await repository.fetchShoppingItem(with: id) else {
            return
        }
        item.moveToDeleted()
        try await repository.addOrUpdateShoppingItem(item)
    }
    
    func moveShoppingItemsToDeleted(with ids: [UUID]) async throws {
        var items = try await repository.fetchShoppingItems(with: ids)
        guard !items.isEmpty else { return }
        for i in items.indices {
            items[i].moveToDeleted()
            try await repository.addOrUpdateShoppingItem(items[i])
        }
    }
    
    func restoreShoppingItem(with id: UUID, toList listID: UUID) async throws {
        guard let _ = try await repository.fetchShoppingList(with: listID) else {
            throw NSError(domain: "Repository", code: 404, userInfo: [NSLocalizedDescriptionKey: "List not found"])
        }
        guard var item = try await repository.fetchShoppingItem(with: id) else {
            return
        }
        let maxOrder = try await repository.fetchMaxOrderOfShoppingItems(ofList: listID)
        item.moveToShoppingList(with: listID, order: maxOrder + 1)
        try await repository.addOrUpdateShoppingItem(item)
    }
    
    func deleteOldTrashedShoppingItems(olderThan days: Int) async throws {
        print("DataManager.deleteOldTrashedItems(olderThan: \(days))")
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -days, to: Date())!
        
        let trashedItems = try await repository.fetchDeletedShoppingItems()
        let oldItems = trashedItems.filter { item in
            if let deletedAt = item.deletedAt {
                return deletedAt < cutoffDate
            }
            return false
        }
        
        let idsToDelete = oldItems.map { $0.id }
        try await deleteShoppingItems(with: idsToDelete)
    }
    
    func deleteShoppingItem(with id: UUID) async throws {
        try await repository.deleteShoppingItem(with: id)
    }
    
    func deleteShoppingItems(with ids: [UUID]) async throws {
        try await repository.deleteShoppingItems(with: ids)
    }
    
    func deleteShoppingItems() async throws {
        try await repository.deleteShoppingItems()
    }
    
    func cleanOrphanedShoppingItems() async throws {
        print("DataManager.cleanOrphanedItems()")
        try await repository.cleanOrphanedShoppingItems()
    }
    
    func fetchShoppingItemImageIDs() async throws -> Set<String> {
        return try await repository.fetchShoppingItemImageIDs()
    }
    
    func fetchShoppingItemsWithMissingImages() async throws -> [ShoppingItem] {
        return try await repository.fetchShoppingItemsWithMissingImages()
    }
    
    func fetchMaxOrderOfShoppingItems(ofList listID: UUID) async throws -> Int {
        return try await repository.fetchMaxOrderOfShoppingItems(ofList: listID)
    }
    
    func fetchMaxOrderOfShoppingItems(ofList listID: UUID, status: ShoppingItemStatus) async throws -> Int {
        return try await repository.fetchMaxOrderOfShoppingItems(ofList: listID, status: status)
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
    
    func deleteLoyaltyCards() async throws {
        try await repository.deleteLoyaltyCards()
    }
    
    func fetchLoyaltyCardImageIDs() async throws -> Set<String> {
        return try await repository.fetchLoyaltyCardImageIDs()
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
    
    func listFiles(in base: StorageLocation, subfolders: [String]?) -> [String] {
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
