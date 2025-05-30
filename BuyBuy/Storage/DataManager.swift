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
    private let imageStorage: ImageStorageServiceProtocol

    init(repository: ShoppingListsRepositoryProtocol,
         imageStorage: ImageStorageServiceProtocol) {
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
        try await repository.addOrUpdateList(list)
    }
    
    func deleteList(with id: UUID) async throws {
        try await repository.deleteList(with: id)
    }
    
    func deleteLists(with ids: [UUID]) async throws {
        try await repository.deleteLists(with: ids)
    }

    // Shopping items
    func fetchItems(for listID: UUID) async throws -> [ShoppingItem] {
        return try await repository.fetchItems(for: listID)
    }
    
    func addOrUpdateItem(_ item: ShoppingItem) async throws {
        try await repository.addOrUpdateItem(item)
    }
    
    func deleteItem(with id: UUID) async throws {
        try await repository.deleteItem(with: id)
    }
    
    func deleteItems(with ids: [UUID]) async throws {
        try await repository.deleteItems(with: ids)
    }
    
    // Data cleaning
    func cleanOrphanedItems() async throws {
        try await repository.cleanOrphanedItems()
    }
    
    // MARK: - ImageStorageService
    
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

//    func addOrUpdateItem(_ item: ShoppingItem) async throws {
//        let orphanedIDs = try await repository.addOrUpdateItem(item)
//        try await imageStorage.deleteImages(withIDs: orphanedIDs)
//    }

//    func deleteItem(_ item: ShoppingItem) async throws {
//        try await repository.deleteItem(item)
//        for id in item.imageIDs {
//            try await imageStorage.deleteImage(baseFileName: id)
//            try await imageStorage.deleteThumbnail(baseFileName: id)
//        }
//    }
}
