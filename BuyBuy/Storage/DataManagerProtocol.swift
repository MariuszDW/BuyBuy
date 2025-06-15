//
//  DataManagerProtocol.swift
//  BuyBuy
//
//  Created by MDW on 30/05/2025.
//

import Foundation
import SwiftUI

@MainActor
protocol DataManagerProtocol {
    // Shopping lists
    func fetchAllLists() async throws -> [ShoppingList]
    func fetchList(with id: UUID) async throws -> ShoppingList?
    func addOrUpdateList(_ list: ShoppingList) async throws
    func deleteList(with id: UUID) async throws
    func deleteLists(with ids: [UUID]) async throws

    // Shopping items
    func fetchItemsOfList(with listID: UUID) async throws -> [ShoppingItem]
    func fetchItem(with id: UUID) async throws -> ShoppingItem?
    func fetchDeletedItems() async throws -> [ShoppingItem]
    func addOrUpdateItem(_ item: ShoppingItem) async throws
    func moveItemToDeleted(with id: UUID) async throws
    func restoreItem(with id: UUID, toList listID: UUID) async throws
    func deleteOldTrashedItems(olderThan days: Int) async throws
    func deleteItem(with id: UUID) async throws
    func deleteItems(with ids: [UUID]) async throws
    func cleanOrphanedItems() async throws
    
    // Loyalty cards
    func fetchLoyaltyCards() async throws -> [LoyaltyCard]
    func fetchLoyaltyCard(with id: UUID) async throws -> LoyaltyCard?
    func addOrUpdateLoyaltyCard(_ card: LoyaltyCard) async throws
    func deleteLoyaltyCard(with id: UUID) async throws
    
    // Images
    func saveImage(_ image: UIImage, baseFileName: String, type: ImageType) async throws
    func saveImage(_ image: UIImage, baseFileName: String, types: [ImageType]) async throws
    func loadImage(baseFileName: String, type: ImageType) async throws -> UIImage
    func deleteImage(baseFileName: String, type: ImageType) async throws
    func deleteImage(baseFileName: String, types: [ImageType]) async throws
    
    // Image cache
    func cleanImageCache() async
    func cleanOrphanedItemImages() async throws
    func cleanOrphanedCardImages() async throws
}
