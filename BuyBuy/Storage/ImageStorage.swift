//
//  ImageStorage.swift
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

actor ImageStorage: ImageStorageProtocol {
    enum ImageType {
        case item
        case card
        
        var folderName: String {
            switch self {
            case .item: return ImageStorageHelper.itemImagesFolderName
            case .card: return ImageStorageHelper.cardImagesFolderName
            }
        }
    }
    
    private let thumbnailCache = NSCache<NSString, UIImage>()
    
    func clearThumbnailCache() async {
        thumbnailCache.removeAllObjects()
    }
    
    // MARK: - Item images
    
    func saveItemImage(_ image: UIImage, baseFileName: String) async throws {
        try await saveImage(image, baseFileName: baseFileName, type: .item)
    }
    
    func saveItemThumbnail(for image: UIImage, baseFileName: String) async throws {
        try await saveThumbnail(for: image, baseFileName: baseFileName, type: .item)
    }
    
    func saveItemImageAndThumbnail(_ image: UIImage, baseFileName: String) async throws {
        try await saveImageAndThumbnail(image, baseFileName: baseFileName, type: .item)
    }
    
    func loadItemImage(baseFileName: String) async throws -> UIImage {
        try await loadImage(baseFileName: baseFileName, type: .item)
    }
    
    func loadItemThumbnail(baseFileName: String) async throws -> UIImage {
        try await loadThumbnail(baseFileName: baseFileName, type: .item)
    }
    
    func deleteItemImage(baseFileName: String) async throws {
        try await deleteImage(baseFileName: baseFileName, type: .item)
    }
    
    func deleteItemThumbnail(baseFileName: String) async throws {
        try await deleteThumbnail(baseFileName: baseFileName, type: .item)
    }
    
    func deleteItemImageAndThumbnail(baseFileName: String) async throws {
        try await deleteImageAndThumbnail(baseFileName: baseFileName, type: .item)
    }
    
    func listAllItemImageBaseNames() async throws -> Set<String> {
        try await listAllImageBaseNames(in: .item)
    }
    
    // MARK: - Card images
    
    func saveCardImage(_ image: UIImage, baseFileName: String) async throws {
        try await saveImage(image, baseFileName: baseFileName, type: .card)
    }
    
    func saveCardThumbnail(for image: UIImage, baseFileName: String) async throws {
        try await saveThumbnail(for: image, baseFileName: baseFileName, type: .card)
    }
    
    func saveCardImageAndThumbnail(_ image: UIImage, baseFileName: String) async throws {
        try await saveImageAndThumbnail(image, baseFileName: baseFileName, type: .card)
    }
    
    func loadCardImage(baseFileName: String) async throws -> UIImage {
        try await loadImage(baseFileName: baseFileName, type: .card)
    }
    
    func loadCardThumbnail(baseFileName: String) async throws -> UIImage {
        try await loadThumbnail(baseFileName: baseFileName, type: .card)
    }
    
    func deleteCardImage(baseFileName: String) async throws {
        try await deleteImage(baseFileName: baseFileName, type: .card)
    }
    
    func deleteCardThumbnail(baseFileName: String) async throws {
        try await deleteThumbnail(baseFileName: baseFileName, type: .card)
    }
    
    func deleteCardImageAndThumbnail(baseFileName: String) async throws {
        try await deleteImageAndThumbnail(baseFileName: baseFileName, type: .card)
    }
    
    func listAllCardImageBaseNames() async throws -> Set<String> {
        try await listAllImageBaseNames(in: .card)
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
    
    private func saveImage(_ image: UIImage, baseFileName: String, type: ImageType) async throws {
        guard let data = image.jpegData(compressionQuality: 0.8) else {
            throw ImageStorageError.failedToSaveImage
        }
        let fileName = ImageStorageHelper.imageFileName(for: baseFileName)
        try await writeData(data, to: fileName, in: type)
    }
    
    private func saveThumbnail(for image: UIImage, baseFileName: String, type: ImageType) async throws {
        guard let thumbnail = await createThumbnail(from: image) else {
            throw ImageStorageError.failedToSaveThumbnail
        }
        guard let data = thumbnail.jpegData(compressionQuality: 0.7) else {
            throw ImageStorageError.failedToSaveThumbnail
        }
        let fileName = ImageStorageHelper.thumbnailFileName(for: baseFileName)
        try await writeData(data, to: fileName, in: type)
    }
    
    private func saveImageAndThumbnail(_ image: UIImage, baseFileName: String, type: ImageType) async throws {
        try await saveImage(image, baseFileName: baseFileName, type: type)
        try await saveThumbnail(for: image, baseFileName: baseFileName, type: type)
    }
    
    private func loadImage(baseFileName: String, type: ImageType) async throws -> UIImage {
        let fileName = ImageStorageHelper.imageFileName(for: baseFileName)
        let data = try await readData(from: fileName, in: type)
        guard let image = UIImage(data: data) else {
            throw ImageStorageError.imageNotFound
        }
        return image
    }
    
    private func loadThumbnail(baseFileName: String, type: ImageType) async throws -> UIImage {
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
    
    private func deleteImage(baseFileName: String, type: ImageType) async throws {
        let fileName = ImageStorageHelper.imageFileName(for: baseFileName)
        try await deleteData(fileName: fileName, in: type)
    }
    
    private func deleteThumbnail(baseFileName: String, type: ImageType) async throws {
        let fileName = ImageStorageHelper.thumbnailFileName(for: baseFileName)
        try await deleteData(fileName: fileName, in: type)
    }
    
    private func deleteImageAndThumbnail(baseFileName: String, type: ImageType) async throws {
        try await deleteImage(baseFileName: baseFileName, type: type)
        try await deleteThumbnail(baseFileName: baseFileName, type: type)
    }
    
    private func listAllImageBaseNames(in type: ImageType) async throws -> Set<String> {
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
