//
//  ImageStorage.swift
//  BuyBuy
//
//  Created by MDW on 27/05/2025.
//

import SwiftUI

enum ImageStorageError: Int, Error { // TODO: zrobic porzadek z tymi errorami, bo wlasciwie nie sa uzywane
    case failedToSaveImage = 1
    case failedToSaveThumbnail = 2
    case imageNotFound = 3
}

struct ImageStorageHelper {
    static let imageSuffix = ".jpg"
    static let thumbnailSuffix = "_thumb.jpg"
    static let itemImagesFolderName = "item_images"
    static let cardImagesFolderName = "card_images"
    
    static func thumbnailFileName(for baseFileName: String) -> String {
        return baseFileName + thumbnailSuffix
    }
    
    static func imageFileName(for baseFileName: String) -> String {
        return baseFileName + imageSuffix
    }
    
    static let thumbnailSize = CGSize(width: 64, height: 64)
}

enum ImageType { // TODO: Rozszerzyc enum do itemImage, itemThumbnail, cardItem, cardThumbnail
    case item
    case card
    
    var folderName: String {
        switch self {
        case .item: return ImageStorageHelper.itemImagesFolderName
        case .card: return ImageStorageHelper.cardImagesFolderName
        }
    }
}

actor ImageStorage: ImageStorageProtocol {
    private let thumbnailCache = NSCache<NSString, UIImage>()
    
    func cleanThumbnailCache() async {
        thumbnailCache.removeAllObjects()
    }
    
    func saveImage(_ image: UIImage, baseFileName: String, type: ImageType) async throws {
        guard let data = image.jpegData(compressionQuality: 0.8) else {
            throw ImageStorageError.failedToSaveImage
        }
        let fileName = ImageStorageHelper.imageFileName(for: baseFileName)
        try await writeData(data, to: fileName, in: type)
    }
    
    func saveThumbnail(for image: UIImage, baseFileName: String, type: ImageType) async throws {
        guard let thumbnail = await createThumbnail(from: image) else {
            throw ImageStorageError.failedToSaveThumbnail
        }
        guard let data = thumbnail.jpegData(compressionQuality: 0.7) else {
            throw ImageStorageError.failedToSaveThumbnail
        }
        let fileName = ImageStorageHelper.thumbnailFileName(for: baseFileName)
        try await writeData(data, to: fileName, in: type)
    }
    
    func saveImageAndThumbnail(_ image: UIImage, baseFileName: String, type: ImageType) async throws {
        try await saveImage(image, baseFileName: baseFileName, type: type)
        try await saveThumbnail(for: image, baseFileName: baseFileName, type: type)
    }
    
    func loadImage(baseFileName: String, type: ImageType) async throws -> UIImage {
        let fileName = ImageStorageHelper.imageFileName(for: baseFileName)
        let data = try await readData(from: fileName, in: type)
        guard let image = UIImage(data: data) else {
            throw ImageStorageError.imageNotFound
        }
        return image
    }
    
    func loadThumbnail(baseFileName: String, type: ImageType) async throws -> UIImage {
        let cacheKey = "\(type.folderName)_\(baseFileName)" as NSString
        if let cached = thumbnailCache.object(forKey: cacheKey) {
            print("Thumbnail \(baseFileName) loaded from cache.")
            return cached
        }
        let fileName = ImageStorageHelper.thumbnailFileName(for: baseFileName)
        let data = try await readData(from: fileName, in: type)
        guard let image = UIImage(data: data) else {
            throw ImageStorageError.imageNotFound
        }
        thumbnailCache.setObject(image, forKey: cacheKey)
        print("Thumbnail \(baseFileName) loaded.")
        return image
    }
    
    func deleteImage(baseFileName: String, type: ImageType) async throws {
        let fileName = ImageStorageHelper.imageFileName(for: baseFileName)
        try await deleteData(fileName: fileName, in: type)
    }
    
    func deleteThumbnail(baseFileName: String, type: ImageType) async throws {
        let fileName = ImageStorageHelper.thumbnailFileName(for: baseFileName)
        try await deleteData(fileName: fileName, in: type)
    }
    
    func deleteImageAndThumbnail(baseFileName: String, type: ImageType) async throws {
        try await deleteImage(baseFileName: baseFileName, type: type)
        try await deleteThumbnail(baseFileName: baseFileName, type: type)
    }
    
    func listAllImageBaseNames(type: ImageType) async throws -> Set<String> {
        let fileManager = FileManager.default
        let fileNames = try fileManager.contentsOfDirectory(atPath: Self.directoryURL(for: type).path)
        
        let baseFileNames = Set(fileNames.compactMap { file -> String? in
            var name = file
            if name.hasSuffix(ImageStorageHelper.thumbnailSuffix) {
                name = String(name.dropLast(ImageStorageHelper.thumbnailSuffix.count))
            } else if name.hasSuffix(ImageStorageHelper.imageSuffix) {
                name = String(name.dropLast(ImageStorageHelper.imageSuffix.count))
            }
            return name
        })
        return baseFileNames
    }
    
    // MARK: - Private common methods
    
    private static func directoryURL(for type: ImageType) -> URL {
        let fileManager = FileManager.default
        let documents = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let folderURL = documents.appendingPathComponent(type.folderName)
        if !fileManager.fileExists(atPath: folderURL.path) {
            try? fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true)
        }
        return folderURL
    }
    
    // MARK: - Private file operations
    
    private func writeData(_ data: Data, to fileName: String, in type: ImageType) async throws {
        try await Task.detached {
            let fileURL = Self.directoryURL(for: type).appendingPathComponent(fileName)
            try data.write(to: fileURL)
        }.value
    }
    
    private func readData(from fileName: String, in type: ImageType) async throws -> Data {
        try await Task.detached {
            let fileURL = Self.directoryURL(for: type).appendingPathComponent(fileName)
            guard FileManager.default.fileExists(atPath: fileURL.path) else {
                throw ImageStorageError.imageNotFound
            }
            return try Data(contentsOf: fileURL)
        }.value
    }
    
    private func deleteData(fileName: String, in type: ImageType) async throws {
        try await Task.detached {
            let fileURL = Self.directoryURL(for: type).appendingPathComponent(fileName)
            if FileManager.default.fileExists(atPath: fileURL.path) {
                try FileManager.default.removeItem(at: fileURL)
            }
        }.value
    }
    
    // MARK: - Thumbnail creation
    
    private func createThumbnail(from image: UIImage) async -> UIImage? {
        let originalSize = image.size
        let squareLength = min(originalSize.width, originalSize.height)
        
        let cropOriginX = (originalSize.width - squareLength) / 2
        let cropOriginY = (originalSize.height - squareLength) / 2
        let cropRect = CGRect(x: cropOriginX, y: cropOriginY, width: squareLength, height: squareLength)
        
        guard let cgImage = image.cgImage?.cropping(to: cropRect) else {
            return nil
        }
        
        let croppedImage = UIImage(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
        
        let renderer = UIGraphicsImageRenderer(size: ImageStorageHelper.thumbnailSize)
        let thumbnail = renderer.image { _ in
            croppedImage.draw(in: CGRect(origin: .zero, size: ImageStorageHelper.thumbnailSize))
        }
        
        return thumbnail
    }
}
