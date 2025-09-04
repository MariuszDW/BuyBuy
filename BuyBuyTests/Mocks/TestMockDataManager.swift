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
    var addOrUpdateShoppingItemHandler: ((BuyBuy.ShoppingItem) -> Void)?
    var fetchShoppingListHandler: ((UUID) -> Void)?
    
    var cloud: Bool = false
    
    var coreDataStack: any BuyBuy.CoreDataStackProtocol = MockCoreDataStack()
    
    var storageManager: any BuyBuy.StorageManagerProtocol = StorageManager()
    
    func setup(useCloud: Bool) async {
    }
    
    func fetchShoppingLists() async throws -> [BuyBuy.ShoppingList] {
        return []
    }
    
    func fetchShoppingList(with id: UUID) async throws -> BuyBuy.ShoppingList? {
        fetchShoppingListHandler?(id)
        return nil
    }
    
    func addOrUpdateShoppingList(_ list: BuyBuy.ShoppingList) async throws {
    }
    
    func deleteShoppingList(with id: UUID, moveItemsToDeleted: Bool) async throws {
    }
    
    func deleteShoppingLists(with ids: [UUID], moveItemsToDeleted: Bool) async throws {
    }
    
    func deleteShoppingLists() async throws {
    }
    
    func fetchShoppingItems() async throws -> [BuyBuy.ShoppingItem] {
        return []
    }
    
    func fetchShoppingItemsOfList(with listID: UUID) async throws -> [BuyBuy.ShoppingItem] {
        return []
    }
    
    func fetchShoppingItem(with id: UUID) async throws -> BuyBuy.ShoppingItem? {
        return nil
    }
    
    func fetchDeletedShoppingItems() async throws -> [BuyBuy.ShoppingItem] {
        return []
    }
    
    func addOrUpdateShoppingItem(_ item: BuyBuy.ShoppingItem) async throws {
        addOrUpdateShoppingItemHandler?(item)
    }
    
    func moveShoppingItemToDeleted(with id: UUID) async throws {
    }
    
    func moveShoppingItemsToDeleted(with ids: [UUID]) async throws {
    }
    
    func restoreShoppingItem(with id: UUID, toList listID: UUID) async throws {
    }
    
    func deleteOldTrashedShoppingItems(olderThan days: Int) async throws {
    }
    
    func deleteShoppingItem(with id: UUID) async throws {
    }
    
    func deleteShoppingItems(with ids: [UUID]) async throws {
    }
    
    func deleteShoppingItems() async throws {
    }
    
    func cleanOrphanedShoppingItems() async throws {
    }
    
    func fetchShoppingItemImageIDs() async throws -> Set<String> {
        return Set<String>()
    }
    
    func fetchShoppingItemsWithMissingImages() async throws -> [BuyBuy.ShoppingItem] {
        return []
    }
    
    func fetchMaxOrderOfShoppingItems(ofList listID: UUID) async throws -> Int {
        return 0
    }
    
    func fetchMaxOrderOfShoppingItems(ofList listID: UUID, status: BuyBuy.ShoppingItemStatus) async throws -> Int {
        return 0
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
    
    func deleteLoyaltyCards() async throws {
    }
    
    func fetchLoyaltyCardImageIDs() async throws -> Set<String> {
        return Set<String>()
    }
    
    func fetchLoyaltyCardsWithMissingImages() async throws -> [BuyBuy.LoyaltyCard] {
        return []
    }
    
    func saveImageToTemporaryDir(_ image: UIImage, baseFileName: String) async throws {
    }
    
    func loadImage(with baseFileName: String) async throws -> UIImage? {
        return nil
    }
    
    func loadThumbnail(with baseFileName: String) async throws -> UIImage? {
        return nil
    }
    
    func cleanImageCache() async {
    }
    
    func cleanTemporaryImages() async {
    }
    
    func saveFile(fileName: String, from base: BuyBuy.StorageLocation, subfolders: [String]?, data: Data) {
    }
    
    func readFile(named fileName: String, from base: BuyBuy.StorageLocation, subfolders: [String]?) -> Data? {
        return nil
    }
    
    func deleteFile(named fileName: String, in base: BuyBuy.StorageLocation, subfolders: [String]?) {
    }
    
    func listFiles(in base: BuyBuy.StorageLocation, subfolders: [String]?) -> [String] {
        return []
    }
    
    func refreshAllCloudData() async {
    }
    
    
    
//    func fetchShoppingLists() async throws -> [BuyBuy.ShoppingList] {
//        return []
//    }
//    
//    func fetchShoppingList(with id: UUID) async throws -> BuyBuy.ShoppingList? {
//        fetchShoppingListHandler?(id)
//        return nil
//    }
//    
//    func addOrUpdateShoppingList(_ list: BuyBuy.ShoppingList) async throws {
//    }
//    
//    func deleteShoppingList(with id: UUID, moveItemsToDeleted: Bool) async throws {
//    }
//    
//    func deleteShoppingLists(with ids: [UUID], moveItemsToDeleted: Bool) async throws {
//    }
//    
//    func fetchShoppingItemsOfList(with listID: UUID) async throws -> [BuyBuy.ShoppingItem] {
//        return []
//    }
//    
//    func fetchShoppingItem(with id: UUID) async throws -> BuyBuy.ShoppingItem? {
//        return nil
//    }
//    
//    func fetchDeletedShoppingItems() async throws -> [BuyBuy.ShoppingItem] {
//        return []
//    }
//    
//    func addOrUpdateShoppingItem(_ item: BuyBuy.ShoppingItem) async throws {
//        addOrUpdateShoppingItemHandler?(item)
//    }
//    
//    func moveShoppingItemToDeleted(with id: UUID) async throws {
//    }
//    
//    func restoreShoppingItem(with id: UUID, toList listID: UUID) async throws {
//    }
//    
//    func deleteOldTrashedShoppingItems(olderThan days: Int) async throws {
//    }
//    
//    func deleteShoppingItem(with id: UUID) async throws {
//    }
//    
//    func deleteShoppingItems(with ids: [UUID]) async throws {
//    }
//    
//    func cleanOrphanedShoppingItems() async throws {
//    }
//    
//    func fetchLoyaltyCards() async throws -> [BuyBuy.LoyaltyCard] {
//        return []
//    }
//    
//    func fetchLoyaltyCard(with id: UUID) async throws -> BuyBuy.LoyaltyCard? {
//        return nil
//    }
//    
//    func addOrUpdateLoyaltyCard(_ card: BuyBuy.LoyaltyCard) async throws {
//    }
//    
//    func deleteLoyaltyCard(with id: UUID) async throws {
//    }
//    
//    func saveImage(_ image: UIImage, baseFileName: String, type: BuyBuy.ImageType) async throws {
//    }
//    
//    func saveImage(_ image: UIImage, baseFileName: String, types: [BuyBuy.ImageType]) async throws {
//    }
//    
//    func loadImage(baseFileName: String, type: BuyBuy.ImageType) async throws -> UIImage {
//        return UIImage()
//    }
//    
//    func deleteImage(baseFileName: String, type: BuyBuy.ImageType) async throws {
//    }
//    
//    func deleteImage(baseFileName: String, types: [BuyBuy.ImageType]) async throws {
//    }
//    
//    func cleanImageCache() async {
//    }
//    
//    func cleanOrphanedItemImages() async throws {
//    }
//    
//    func cleanOrphanedCardImages() async throws {
//    }
//    
//    func saveFile(data: Data, fileName: String) async throws {
//    }
//    
//    func readFile(fileName: String) async throws -> Data {
//        return Data()
//    }
//    
//    func deleteFile(fileName: String) async throws {
//    }
//    
//    func listFiles() async throws -> [String] {
//        return []
//    }
}
