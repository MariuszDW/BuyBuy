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
    case failedToResolveDirectory = 4
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
        print("Clean image cache.")
        cache.removeAllObjects()
    }
    
    func save(image: UIImage, baseFileName: String, type: ImageType, cloud: Bool) async throws {
        guard let imageToSave = type.isThumbnail ? await createThumbnail(from: image) : image else {
            throw ImageStorageError.failedToSaveImage
        }
        
        guard let data = imageToSave.jpegData(compressionQuality: type.jpegCompressionQuality) else {
            throw ImageStorageError.failedToSaveImage
        }
        
        let fileName = type.fileName(for: baseFileName)
        try await writeData(data, to: fileName, type: type, cloud: cloud)
        print("Image \(fileName) saved.")
    }
    
    func save(data: Data, baseFileName: String, type: ImageType, cloud: Bool) async throws {
        let fileName = type.fileName(for: baseFileName)
        try await writeData(data, to: fileName, type: type, cloud: cloud)
        print("Raw image data \(fileName) saved.")
    }
    
    func loadImage(baseFileName: String, type: ImageType, cloud: Bool) async throws -> UIImage? {
        let cacheKey: NSString = type.useCache ? type.cacheKey(for: baseFileName) : ""
        
        if type.useCache, let cached = cache.object(forKey: cacheKey) {
            print("Image \(baseFileName) loaded from cache.")
            return cached
        }
        
        let fileName = type.fileName(for: baseFileName)
        
        guard let data = try await readData(from: fileName, type: type, cloud: cloud) else {
            print("Image \(fileName) not found.")
            return nil
        }
        
        guard let image = UIImage(data: data) else {
            throw ImageStorageError.imageNotFound
        }
        
        if type.useCache {
            cache.setObject(image, forKey: cacheKey)
        }
        
        print("Image \(fileName) loaded.")
        return image
    }
    
    func deleteImage(baseFileName: String, type: ImageType, cloud: Bool) async throws {
        let fileName = type.fileName(for: baseFileName)
        try await deleteData(fileName: fileName, type: type, cloud: cloud)
        print("Image \(fileName) deleted.")
    }
    
    func deleteImage(baseFileName: String, types: [ImageType], cloud: Bool) async throws {
        for type in types {
            try await deleteImage(baseFileName: baseFileName, type: type, cloud: cloud)
        }
    }
    
    func listImageBaseNames(type: ImageType, cloud: Bool) async throws -> Set<String> {
        let fileManager = FileManager.default
        guard let directoryPath = Self.directoryURL(for: type, cloud: cloud)?.path else {
            return Set<String>()
        }
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
    
    // MARK: - Static functions
    
    static func existingFileURL(for baseFileName: String, type: ImageType, cloud: Bool) -> URL? {
        guard let dir = Self.directoryURL(for: type, cloud: cloud) else { return nil }
        let fileURL = dir.appendingPathComponent(type.fileName(for: baseFileName))
        return FileManager.default.fileExists(atPath: fileURL.path) ? fileURL : nil
    }
    
    static func fileURL(for baseFileName: String, type: ImageType, cloud: Bool) -> URL? {
        guard let directory = Self.directoryURL(for: type, cloud: cloud) else { return nil }
        return directory.appendingPathComponent(type.fileName(for: baseFileName))
    }
    
    static func directoryURL(for type: ImageType, cloud: Bool) -> URL? {
        let fileManager = FileManager.default
        let baseDirectoryURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(cloud ? "cloud" : "device", isDirectory: true)
        let imagesFolderURL = baseDirectoryURL.appendingPathComponent(type.folderName, isDirectory: true)
        if !fileManager.fileExists(atPath: imagesFolderURL.path) {
            do {
                try fileManager.createDirectory(at: imagesFolderURL, withIntermediateDirectories: true)
                print("Created folder at \(imagesFolderURL.path)")
            } catch {
                print("Failed to create directory at \(imagesFolderURL.path): \(error.localizedDescription)")
                return nil
            }
        }
        return imagesFolderURL
    }
    
    // MARK: - Private file operations
    
    private func writeData(_ data: Data, to fileName: String, type: ImageType, cloud: Bool) async throws {
        guard let dir = Self.directoryURL(for: type, cloud: cloud) else { return }
        let fileURL = dir.appendingPathComponent(fileName) // TODO: deprecated
        print("ImageStorage - write image: \"\(fileURL)\"")
        
        try await Task.detached {
            try data.write(to: fileURL)
        }.value
    }
    
    private func readData(from fileName: String, type: ImageType, cloud: Bool) async throws -> Data? {
        guard let dir = Self.directoryURL(for: type, cloud: cloud) else { return nil }
        let fileURL = dir.appendingPathComponent(fileName) // TODO: deprecated
        print("ImageStorage - read image: \"\(fileURL)\"")

        return try await Task.detached {
            guard FileManager.default.fileExists(atPath: fileURL.path) else {
                throw ImageStorageError.imageNotFound
            }

            return try Data(contentsOf: fileURL)
        }.value
    }
    
    private func deleteData(fileName: String, type: ImageType, cloud: Bool) async throws {
        guard let dir = Self.directoryURL(for: type, cloud: cloud) else { return }
        let fileURL = dir.appendingPathComponent(fileName) // TODO: deprecated
        print("ImageStorage - delete image: \"\(fileURL)\"")
        
        try await Task.detached {
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
