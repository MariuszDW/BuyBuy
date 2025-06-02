//
//  ImageStorageProtocol.swift
//  BuyBuy
//
//  Created by MDW on 28/05/2025.
//

import UIKit

protocol ImageStorageProtocol: Sendable {
    // Thumbnail cache
    func cleanThumbnailCache() async
    
    // Item images
    func saveItemImage(_ image: UIImage, baseFileName: String) async throws
    func saveItemThumbnail(for image: UIImage, baseFileName: String) async throws
    func saveItemImageAndThumbnail(_ image: UIImage, baseFileName: String) async throws
    func loadItemImage(baseFileName: String) async throws -> UIImage
    func loadItemThumbnail(baseFileName: String) async throws -> UIImage
    func deleteItemImage(baseFileName: String) async throws
    func deleteItemThumbnail(baseFileName: String) async throws
    func deleteItemImageAndThumbnail(baseFileName: String) async throws
    func listAllItemImageBaseNames() async throws -> Set<String>
    
    // Card images
    func saveCardImage(_ image: UIImage, baseFileName: String) async throws
    func saveCardThumbnail(for image: UIImage, baseFileName: String) async throws
    func saveCardImageAndThumbnail(_ image: UIImage, baseFileName: String) async throws
    func loadCardImage(baseFileName: String) async throws -> UIImage
    func loadCardThumbnail(baseFileName: String) async throws -> UIImage
    func deleteCardImage(baseFileName: String) async throws
    func deleteCardThumbnail(baseFileName: String) async throws
    func deleteCardImageAndThumbnail(baseFileName: String) async throws
    func listAllCardImageBaseNames() async throws -> Set<String>
}
