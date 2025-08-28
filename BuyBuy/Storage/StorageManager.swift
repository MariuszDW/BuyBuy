//
//  StorageManager.swift
//  BuyBuy
//
//  Created by MDW on 10/08/2025.
//

import Foundation
import UIKit

enum StorageLocation {
    case none
    case localDocuments
    case cloudDocuments
    case caches
    case temporary
    
    var url: URL? {
        switch self {
        case .none:
            return URL(string: "")
        case .localDocuments:
            return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        case .cloudDocuments:
            guard let containerURL = FileManager.default.url(forUbiquityContainerIdentifier: AppConstants.iCloudContainerID) else {
                print("iCloud container \(AppConstants.iCloudContainerID) not available")
                return nil
            }
            return containerURL.appending(path: "Documents", directoryHint: .isDirectory)
        case .caches:
            return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
        case .temporary:
            return FileManager.default.temporaryDirectory
        }
    }
}

class StorageManager: StorageManagerProtocol {
    private let fileManager: FileManager
    
    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }
    
    // MARK: - URL helpers
    
    private func baseURL(for base: StorageLocation) -> URL? {
        guard let url = base.url, !url.absoluteString.isEmpty else { return nil }
        return url
    }
    
    func appending(subfolders: [String]?, to url: URL) -> URL {
        var result = url
        subfolders?.forEach { result.appendPathComponent($0, isDirectory: true) }
        return result
    }
    
    func folderURL(for base: StorageLocation, subfolders: [String]? = nil) -> URL? {
        guard let b = baseURL(for: base) else { return nil }
        return appending(subfolders: subfolders, to: b)
    }
    
    func fileURL(for base: StorageLocation, subfolders: [String]? = nil, fileName: String) -> URL? {
        guard let folder = folderURL(for: base, subfolders: subfolders) else { return nil }
        return folder.appending(path: fileName, directoryHint: .notDirectory)
    }
    
    func existingFileURL(for base: StorageLocation, subfolders: [String]? = nil, fileName: String) -> URL? {
        guard let folder = folderURL(for: base, subfolders: subfolders) else { return nil }
        let fileURL = folder.appending(path: fileName, directoryHint: .notDirectory)
        return fileManager.fileExists(atPath: fileURL.path()) ? fileURL : nil
    }
    
    // MARK: - List
    
    func listFiles(in base: StorageLocation, subfolders: [String]? = nil) -> [URL] {
        return listItems(in: base, subfolders: subfolders, directories: false)
    }
    
    func listDirectories(in base: StorageLocation, subfolders: [String]? = nil) -> [URL] {
        return listItems(in: base, subfolders: subfolders, directories: true)
    }
    
    private func listItems(in base: StorageLocation, subfolders: [String]? = nil, directories: Bool) -> [URL] {
        guard let targetURL = folderURL(for: base, subfolders: subfolders) else { return [] }
        guard let items = try? fileManager.contentsOfDirectory(
            at: targetURL,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: []
        ) else { return [] }
        return items.filter { url in
            (try? url.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) == directories
        }
    }
    
    // MARK: - Exists
    
    func exists(in location: StorageLocation, subpathComponents: [String]? = nil) -> Bool {
        guard let base = baseURL(for: location) else { return false }
        let targetURL = appending(subfolders: subpathComponents, to: base)
        return fileManager.fileExists(atPath: targetURL.path)
    }
    
    // MARK: - Ensure directory
    
    func ensureDirectoryExists(in base: StorageLocation, subfolders: [String]? = nil) throws {
        guard let targetURL = folderURL(for: base, subfolders: subfolders) else { return }
        var isDir: ObjCBool = false
        if !fileManager.fileExists(atPath: targetURL.path, isDirectory: &isDir) || !isDir.boolValue {
            try fileManager.createDirectory(at: targetURL, withIntermediateDirectories: true, attributes: nil)
        }
    }
    
    // MARK: - Delete
    
    func deleteFile(named fileName: String, in base: StorageLocation, subfolders: [String]? = nil) {
        guard let url = fileURL(for: base, subfolders: subfolders, fileName: fileName) else { return }
        try? fileManager.removeItem(at: url)
    }
    
    func deleteFolder(named folderName: String, in base: StorageLocation, subfolders: [String]? = nil) {
        guard let folderURL = folderURL(for: base, subfolders: (subfolders ?? []) + [folderName]) else { return }
        try? fileManager.removeItem(at: folderURL)
    }
    
    // MARK: - Copy
    
    func copyFile(named fileName: String,
                  from sourceBase: StorageLocation,
                  sourceSubfolders: [String]? = nil,
                  to targetBase: StorageLocation,
                  targetSubfolders: [String]? = nil) {
        guard
            let sourceURL = fileURL(for: sourceBase, subfolders: sourceSubfolders, fileName: fileName),
            let targetURL = fileURL(for: targetBase, subfolders: targetSubfolders, fileName: fileName)
        else { return }
        try? ensureDirectoryExists(in: targetBase, subfolders: targetSubfolders)
        try? fileManager.copyItem(at: sourceURL, to: targetURL)
    }
    
    // MARK: - Move
    
    func moveFile(named fileName: String,
                  from sourceBase: StorageLocation,
                  sourceSubfolders: [String]? = nil,
                  to targetBase: StorageLocation,
                  targetSubfolders: [String]? = nil) {
        guard
            let sourceURL = fileURL(for: sourceBase, subfolders: sourceSubfolders, fileName: fileName),
            let targetURL = fileURL(for: targetBase, subfolders: targetSubfolders, fileName: fileName)
        else { return }
        try? ensureDirectoryExists(in: targetBase, subfolders: targetSubfolders)
        try? fileManager.moveItem(at: sourceURL, to: targetURL)
    }
    
    // MARK: - Save
    
    func saveData(_ data: Data, named fileName: String, to base: StorageLocation, subfolders: [String]? = nil) {
        guard let url = fileURL(for: base, subfolders: subfolders, fileName: fileName) else { return }
        try? ensureDirectoryExists(in: base, subfolders: subfolders)
        try? data.write(to: url)
    }
    
    // MARK: - Load
    
    func readData(named fileName: String, from base: StorageLocation, subfolders: [String]? = nil) -> Data? {
        guard let url = fileURL(for: base, subfolders: subfolders, fileName: fileName) else { return nil }
        return try? Data(contentsOf: url)
    }
}
