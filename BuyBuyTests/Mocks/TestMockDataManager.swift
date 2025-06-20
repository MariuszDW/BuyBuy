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
        return []
    }
    
    func fetchList(with id: UUID) async throws -> BuyBuy.ShoppingList? {
        fetchListHandler?(id)
        return nil
    }
    
    func addOrUpdateList(_ list: BuyBuy.ShoppingList) async throws {
    }
    
    func deleteList(with id: UUID, moveItemsToDeleted: Bool) async throws {
    }
    
    func deleteLists(with ids: [UUID], moveItemsToDeleted: Bool) async throws {
    }
    
    func fetchItemsOfList(with listID: UUID) async throws -> [BuyBuy.ShoppingItem] {
        return []
    }
    
    func fetchItem(with id: UUID) async throws -> BuyBuy.ShoppingItem? {
        return nil
    }
    
    func fetchDeletedItems() async throws -> [BuyBuy.ShoppingItem] {
        return []
    }
    
    func addOrUpdateItem(_ item: BuyBuy.ShoppingItem) async throws {
        addOrUpdateItemHandler?(item)
    }
    
    func moveItemToDeleted(with id: UUID) async throws {
    }
    
    func restoreItem(with id: UUID, toList listID: UUID) async throws {
    }
    
    func deleteOldTrashedItems(olderThan days: Int) async throws {
    }
    
    func deleteItem(with id: UUID) async throws {
    }
    
    func deleteItems(with ids: [UUID]) async throws {
    }
    
    func cleanOrphanedItems() async throws {
    }
    
    func fetchLoyaltyCards() async throws -> [BuyBuy.LoyaltyCard] {
        return []
    }
    
    func fetchLoyaltyCard(with id: UUID) async throws -> BuyBuy.LoyaltyCard? {
        return nil
    }
    
    func addOrUpdateLoyaltyCard(_ card: BuyBuy.LoyaltyCard) async throws {
    }
    
    func deleteLoyaltyCard(with id: UUID) async throws {
    }
    
    func saveImage(_ image: UIImage, baseFileName: String, type: BuyBuy.ImageType) async throws {
    }
    
    func saveImage(_ image: UIImage, baseFileName: String, types: [BuyBuy.ImageType]) async throws {
    }
    
    func loadImage(baseFileName: String, type: BuyBuy.ImageType) async throws -> UIImage {
        return UIImage()
    }
    
    func deleteImage(baseFileName: String, type: BuyBuy.ImageType) async throws {
    }
    
    func deleteImage(baseFileName: String, types: [BuyBuy.ImageType]) async throws {
    }
    
    func cleanImageCache() async {
    }
    
    func cleanOrphanedItemImages() async throws {
    }
    
    func cleanOrphanedCardImages() async throws {
    }
    
    func saveFile(data: Data, fileName: String) async throws {
    }
    
    func readFile(fileName: String) async throws -> Data {
        return Data()
    }
    
    func deleteFile(fileName: String) async throws {
    }
    
    func listFiles() async throws -> [String] {
        return []
    }
}
