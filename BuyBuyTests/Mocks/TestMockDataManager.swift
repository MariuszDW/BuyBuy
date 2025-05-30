//
//  TestMockDataManager.swift
//  BuyBuyTests
//
//  Created by MDW on 30/05/2025.
//

import Foundation
import UIKit
@testable import BuyBuy

final class TestMockDataManager: DataManagerProtocol, @unchecked Sendable {
    var addOrUpdateItemHandler: ((BuyBuy.ShoppingItem) -> Void)?
    var fetchListHandler: ((UUID) -> Void)?
    
    func fetchAllLists() async throws -> [BuyBuy.ShoppingList] {
        // TODO: implement...
        return []
    }
    
    func fetchList(with id: UUID) async throws -> BuyBuy.ShoppingList? {
        fetchListHandler?(id)
        return nil
    }
    
    func addOrUpdateList(_ list: BuyBuy.ShoppingList) async throws {
        // TODO: implement...
    }
    
    func deleteList(with id: UUID) async throws {
        // TODO: implement...
    }
    
    func deleteLists(with ids: [UUID]) async throws {
        // TODO: implement...
    }
    
    func fetchItems(for listID: UUID) async throws -> [BuyBuy.ShoppingItem] {
        // TODO: implement...
        return []
    }
    
    func addOrUpdateItem(_ item: BuyBuy.ShoppingItem) async throws {
        addOrUpdateItemHandler?(item)
    }
    
    func deleteItem(with id: UUID) async throws {
        // TODO: implement...
    }
    
    func deleteItems(with ids: [UUID]) async throws {
        // TODO: implement...
    }
    
    func cleanOrphanedItems() async throws {
        // TODO: implement...
    }
    
    func saveImage(_ image: UIImage, baseFileName: String) async throws {
        // TODO: implement...
    }
    
    func saveThumbnail(for image: UIImage, baseFileName: String) async throws {
        // TODO: implement...
    }
    
    func loadImage(baseFileName: String) async throws -> UIImage {
        // TODO: implement...
        return UIImage()
    }
    
    func loadThumbnail(baseFileName: String) async throws -> UIImage {
        // TODO: implement...
        return UIImage()
    }
    
    func deleteImage(baseFileName: String) async throws {
        // TODO: implement...
    }
    
    func deleteThumbnail(baseFileName: String) async throws {
        // TODO: implement...
    }
    
    func clearThumbnailCache() async {
        // TODO: implement...
    }
}
