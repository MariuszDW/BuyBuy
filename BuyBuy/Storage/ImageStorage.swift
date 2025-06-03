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
    static let thumbnailSize = CGSize(width: 64, height: 64)
}

enum ImageType: CaseIterable {
    case itemImage
    case itemThumbnail
    case cardImage
    case cardThumbnail
    
    var folderName: String {
        switch self {
        case .itemImage, .itemThumbnail:
            return "item_images"
        case .cardImage, .cardThumbnail:
            return "card_images"
        }
    }
    
    var fileNameExtension: String {
        return ".jpg"
    }
    
    var fileNameSuffix: String {
        switch self {
        case .itemImage, .cardImage:
            return ""
        case .itemThumbnail, .cardThumbnail:
            return "_thumb"
        }
    }
    
    var isThumbnail: Bool {
        return self == .itemThumbnail || self == .cardThumbnail
    }
    
    var useCache: Bool {
        return self == .itemThumbnail || self == .cardThumbnail
    }
    
    func fileName(for baseFileName: String) -> String {
        return baseFileName + fileNameSuffix + fileNameExtension
    }
    
    func cacheKey(for baseFileName: String) -> NSString {
        return "\(self.folderName)_\(baseFileName)_\(self.fileNameSuffix)" as NSString
    }
    
    var jpegCompressionQuality: CGFloat {
        switch self {
        case .itemImage, .cardImage:
            return 0.8
        case .itemThumbnail, .cardThumbnail:
            return 0.7
        }
    }
}

actor ImageStorage: ImageStorageProtocol {
    private let cache = NSCache<NSString, UIImage>()
    
    func cleanCache() async {
        cache.removeAllObjects()
    }
    
    func saveImage(_ image: UIImage, baseFileName: String, type: ImageType) async throws {
        guard let imageToSave = type.isThumbnail ? await createThumbnail(from: image) : image else {
            throw ImageStorageError.failedToSaveImage
        }
        
        guard let data = imageToSave.jpegData(compressionQuality: type.jpegCompressionQuality) else {
            throw ImageStorageError.failedToSaveImage
        }
        
        let fileName = type.fileName(for: baseFileName)
        try await writeData(data, to: fileName, in: type)
    }
    
    func loadImage(baseFileName: String, type: ImageType) async throws -> UIImage {
        let cacheKey: NSString = type.useCache ? type.cacheKey(for: baseFileName) : ""
        
        if type.useCache {
            if let cached = cache.object(forKey: cacheKey) {
                print("Thumbnail \(baseFileName) loaded from cache.")
                return cached
            }
        }
        
        let fileName = type.fileName(for: baseFileName)
        let data = try await readData(from: fileName, in: type)
        guard let image = UIImage(data: data) else {
            throw ImageStorageError.imageNotFound
        }
        
        if type.useCache {
            cache.setObject(image, forKey: cacheKey)
            print("Thumbnail \(baseFileName) loaded.")
        }
        
        return image
    }
    
    func deleteImage(baseFileName: String, type: ImageType) async throws {
        let fileName = type.fileName(for: baseFileName)
        try await deleteData(fileName: fileName, in: type)
    }
    
    func deleteImage(baseFileName: String, types: [ImageType]) async throws {
        for type in types {
            try await deleteImage(baseFileName: baseFileName, type: type)
        }
    }
    
    func listImageBaseNames(type: ImageType) async throws -> Set<String> {
        let fileManager = FileManager.default
        let directoryPath = Self.directoryURL(for: type).path
        let fileNames = try fileManager.contentsOfDirectory(atPath: directoryPath)
        
        let uniqueSuffixes = Set(ImageType.allCases.map { $0.fileNameSuffix }).filter { !$0.isEmpty }
        
        let baseFileNames = fileNames
            .map { file -> String in
                var name = (file as NSString).deletingPathExtension
                for suffix in uniqueSuffixes {
                    if name.hasSuffix(suffix) {
                        name = String(name.dropLast(suffix.count))
                    }
                }
                return name
            }
        
        return Set(baseFileNames)
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
