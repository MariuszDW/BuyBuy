//
//  ImageStorageProtocol.swift
//  BuyBuy
//
//  Created by MDW on 28/05/2025.
//

import SwiftUI

protocol ImageStorageProtocol: Sendable {
    // Thumbnail cache
    func cleanThumbnailCache() async
    
    // Save image/thumbnail
    func saveImage(_ image: UIImage, baseFileName: String, type: ImageType) async throws
    func saveThumbnail(for image: UIImage, baseFileName: String, type: ImageType) async throws
    func saveImageAndThumbnail(_ image: UIImage, baseFileName: String, type: ImageType) async throws
    
    // Load image/thumbnail
    func loadImage(baseFileName: String, type: ImageType) async throws -> UIImage
    func loadThumbnail(baseFileName: String, type: ImageType) async throws -> UIImage
    
    // Delete image/thumbnail
    func deleteImage(baseFileName: String, type: ImageType) async throws
    func deleteThumbnail(baseFileName: String, type: ImageType) async throws
    func deleteImageAndThumbnail(baseFileName: String, type: ImageType) async throws
    
    // Image names
    func listAllImageBaseNames(type: ImageType) async throws -> Set<String>
}
