//
//  ImageStorageService.swift
//  BuyBuy
//
//  Created by MDW on 27/05/2025.
//

import UIKit

enum ImageStorageError: Int, Error {
    case failedToSaveImage = 1
    case failedToSaveThumbnail = 2
    case imageNotFound = 3
}

struct ImageStorageHelper {
    static func thumbnailFileName(for baseFileName: String) -> String {
        return baseFileName + "_thumb.jpg"
    }
    
    static func imageFileName(for baseFileName: String) -> String {
        return baseFileName + ".jpg"
    }
    
    static let thumbnailSize = CGSize(width: 64, height: 64)
}

actor ImageStorageService: ImageStorageServiceProtocol {
    static private let imagesDirectoryURL: URL = {
        let fileManager = FileManager.default
        let documents = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let imagesURL = documents.appendingPathComponent("images")
        if !fileManager.fileExists(atPath: imagesURL.path) {
            try? fileManager.createDirectory(at: imagesURL, withIntermediateDirectories: true)
        }
        return imagesURL
    }()
    
    private let thumbnailCache = NSCache<NSString, UIImage>()
    
    func clearThumbnailCache() {
        thumbnailCache.removeAllObjects()
    }
    
    // MARK: - Save
    
    func saveThumbnail(for image: UIImage, baseFileName: String) async throws {
        let originalSize = image.size
        let squareLength = min(originalSize.width, originalSize.height)
        
        let cropOriginX = (originalSize.width - squareLength) / 2
        let cropOriginY = (originalSize.height - squareLength) / 2
        let cropRect = CGRect(x: cropOriginX, y: cropOriginY, width: squareLength, height: squareLength)
        
        guard let cgImage = image.cgImage?.cropping(to: cropRect) else {
            throw ImageStorageError.failedToSaveThumbnail
        }
        
        let croppedImage = UIImage(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
        
        let renderer = UIGraphicsImageRenderer(size: ImageStorageHelper.thumbnailSize)
        let thumbnail = renderer.image { _ in
            croppedImage.draw(in: CGRect(origin: .zero, size: ImageStorageHelper.thumbnailSize))
        }
        
        guard let data = thumbnail.jpegData(compressionQuality: 0.7) else {
            throw ImageStorageError.failedToSaveThumbnail
        }
        
        let fileName = ImageStorageHelper.thumbnailFileName(for: baseFileName)
        try await writeData(data, to: fileName)
    }
    
    func saveImage(_ image: UIImage, baseFileName: String) async throws {
        guard let data = image.jpegData(compressionQuality: 0.8) else {
            throw ImageStorageError.failedToSaveImage
        }
        
        let fileName = ImageStorageHelper.imageFileName(for: baseFileName)
        try await writeData(data, to: fileName)
    }
    
    // MARK: - Load
    
    func loadImage(baseFileName: String) async throws -> UIImage {
        let fileName = ImageStorageHelper.imageFileName(for: baseFileName)
        let data = try await readData(from: fileName)
        guard let image = UIImage(data: data) else {
            throw ImageStorageError.imageNotFound
        }
        return image
    }
    
    func loadThumbnail(baseFileName: String) async throws -> UIImage {
        let cacheKey = baseFileName as NSString
        if let cached = thumbnailCache.object(forKey: cacheKey) {
            print("Thumbnail \(baseFileName) loaded from cache.")
            return cached
        }
        let fileName = ImageStorageHelper.thumbnailFileName(for: baseFileName)
        let data = try await readData(from: fileName)
        guard let image = UIImage(data: data) else {
            throw ImageStorageError.imageNotFound
        }
        thumbnailCache.setObject(image, forKey: cacheKey)
        print("Thumbnail \(baseFileName) loaded.")
        return image
    }
    
    // MARK: - Delete
    
    func deleteImage(baseFileName: String) async throws {
        let fileName = ImageStorageHelper.imageFileName(for: baseFileName)
        try await deleteData(fileName: fileName)
    }
    
    func deleteThumbnail(baseFileName: String) async throws {
        let fileName = ImageStorageHelper.thumbnailFileName(for: baseFileName)
        try await deleteData(fileName: fileName)
    }
    
    // MARK: - Private
    
    private func writeData(_ data: Data, to fileName: String) async throws {
        try await Task.detached {
            let fileURL = Self.imagesDirectoryURL.appendingPathComponent(fileName)
            try data.write(to: fileURL)
        }.value
    }
    
    private func readData(from fileName: String) async throws -> Data {
        try await Task.detached {
            let fileURL = Self.imagesDirectoryURL.appendingPathComponent(fileName)
            guard FileManager.default.fileExists(atPath: fileURL.path) else {
                throw ImageStorageError.imageNotFound
            }
            return try Data(contentsOf: fileURL)
        }.value
    }
    
    private func deleteData(fileName: String) async throws {
        try await Task.detached {
            let fileURL = Self.imagesDirectoryURL.appendingPathComponent(fileName)
            if FileManager.default.fileExists(atPath: fileURL.path) {
                try FileManager.default.removeItem(at: fileURL)
            }
        }.value
    }
}
