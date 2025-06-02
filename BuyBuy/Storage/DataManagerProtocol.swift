//
//  DataManagerProtocol.swift
//  BuyBuy
//
//  Created by MDW on 30/05/2025.
//

import Foundation
import UIKit

@MainActor
protocol DataManagerProtocol {
    // Lists
    func fetchAllLists() async throws -> [ShoppingList]
    func fetchList(with id: UUID) async throws -> ShoppingList?
    func addOrUpdateList(_ list: ShoppingList) async throws
    func deleteList(with id: UUID) async throws
    func deleteLists(with ids: [UUID]) async throws

    // Items
    func fetchItemsOfList(with listID: UUID) async throws -> [ShoppingItem]
    func fetchItem(with id: UUID) async throws -> ShoppingItem?
    func addOrUpdateItem(_ item: ShoppingItem) async throws
    func deleteItem(with id: UUID) async throws
    func deleteItems(with ids: [UUID]) async throws
    func cleanOrphanedItems() async throws
    
    // Images - Items
    func saveItemImageAndThumbnail(_ image: UIImage, baseFileName: String) async throws
    func loadItemImage(baseFileName: String) async throws -> UIImage
    func loadItemThumbnail(baseFileName: String) async throws -> UIImage
    func deleteItemImageAndThumbnail(baseFileName: String) async throws
    
    // Images - Cards
    func saveCardImageAndThumbnail(_ image: UIImage, baseFileName: String) async throws
    func loadCardImage(baseFileName: String) async throws -> UIImage
    func loadCardThumbnail(baseFileName: String) async throws -> UIImage
    func deleteCardImageAndThumbnail(baseFileName: String) async throws
    
    func clearThumbnailCache() async
    func cleanOrphanedItemImages() async throws
    func cleanOrphanedCardImages() async throws
}
