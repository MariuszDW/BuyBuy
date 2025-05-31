//
//  ImageStorageProtocol.swift
//  BuyBuy
//
//  Created by MDW on 28/05/2025.
//

import UIKit

protocol ImageStorageProtocol: Sendable {
    func saveImage(_ image: UIImage, baseFileName: String) async throws
    func saveThumbnail(for image: UIImage, baseFileName: String) async throws
    func saveImageAndThumbnail(_ image: UIImage, baseFileName: String) async throws

    func loadImage(baseFileName: String) async throws -> UIImage
    func loadThumbnail(baseFileName: String) async throws -> UIImage

    func deleteImage(baseFileName: String) async throws
    func deleteThumbnail(baseFileName: String) async throws
    func deleteImageAndThumbnail(baseFileName: String) async throws
    
    func clearThumbnailCache() async
}
