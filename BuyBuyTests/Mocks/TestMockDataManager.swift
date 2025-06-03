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
        // TODO: implement...
    }
    
    func deleteList(with id: UUID) async throws {
        // TODO: implement...
    }
    
    func deleteLists(with ids: [UUID]) async throws {
        // TODO: implement...
    }
    
    func fetchItemsOfList(with listID: UUID) async throws -> [BuyBuy.ShoppingItem] {
        // TODO: implement...
        return []
    }
    
    func fetchItem(with id: UUID) async throws -> BuyBuy.ShoppingItem? {
        // TODO: implement...
        return nil
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
    
    func fetchLoyaltyCards() async throws -> [BuyBuy.LoyaltyCard] {
        // TODO: implement...
        return []
    }
    
    func fetchLoyaltyCard(with id: UUID) async throws -> BuyBuy.LoyaltyCard? {
        // TODO: implement...
        return nil
    }
    
    func addOrUpdateLoyaltyCard(_ card: BuyBuy.LoyaltyCard) async throws {
        // TODO: implement...
    }
    
    func deleteLoyaltyCard(with id: UUID) async throws {
        // TODO: implement...
    }
    
    func saveImage(_ image: UIImage, baseFileName: String, type: BuyBuy.ImageType) async throws {
        // TODO: implement...
    }
    
    func saveImage(_ image: UIImage, baseFileName: String, types: [BuyBuy.ImageType]) async throws {
        // TODO: implement...
    }
    
    func loadImage(baseFileName: String, type: BuyBuy.ImageType) async throws -> UIImage {
        // TODO: implement...
        return UIImage()
    }
    
    func deleteImage(baseFileName: String, type: BuyBuy.ImageType) async throws {
        // TODO: implement...
    }
    
    func deleteImage(baseFileName: String, types: [BuyBuy.ImageType]) async throws {
        // TODO: implement...
    }
    
    func cleanImageCache() async {
        // TODO: implement...
    }
    
    func cleanOrphanedItemImages() async throws {
        // TODO: implement...
    }
    
    func cleanOrphanedCardImages() async throws {
        // TODO: implement...
    }
}
