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
    
    // Loyalty Cards
    func fetchLoyaltyCards() async throws -> [LoyaltyCard]
    func fetchLoyaltyCard(with id: UUID) async throws -> LoyaltyCard?
    func addOrUpdateLoyaltyCard(_ card: LoyaltyCard) async throws
    func deleteLoyaltyCard(with id: UUID) async throws
    
    // Images
    func saveImageAndThumbnail(_ image: UIImage, baseFileName: String, type: ImageType) async throws
    func loadImage(baseFileName: String, type: ImageType) async throws -> UIImage
    func loadThumbnail(baseFileName: String, type: ImageType) async throws -> UIImage
    func deleteImageAndThumbnail(baseFileName: String, type: ImageType) async throws
    
    // Cleaning data
    func cleanThumbnailCache() async
    func cleanOrphanedItemImages() async throws
    func cleanOrphanedCardImages() async throws
}
