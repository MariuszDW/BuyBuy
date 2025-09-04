//
//  StorageManagerProtocol.swift
//  BuyBuy
//
//  Created by MDW on 18/08/2025.
//

import Foundation

protocol StorageManagerProtocol {
    func appending(subfolders: [String]?, to url: URL) -> URL
    func folderURL(for base: StorageLocation, subfolders: [String]?) -> URL?
    func fileURL(for base: StorageLocation, subfolders: [String]?, fileName: String) -> URL?
    func existingFileURL(for base: StorageLocation, subfolders: [String]?, fileName: String) -> URL?
    
    func listFiles(in base: StorageLocation, subfolders: [String]?) -> [URL]
    func listDirectories(in base: StorageLocation, subfolders: [String]?) -> [URL]

    func exists(in location: StorageLocation, subpathComponents: [String]?) -> Bool
    func ensureDirectoryExists(in base: StorageLocation, subfolders: [String]?) throws
    
    func deleteFile(named fileName: String, in base: StorageLocation, subfolders: [String]?)
    func deleteFolder(named folderName: String, in base: StorageLocation, subfolders: [String]?)
    
    func copyFile(named fileName: String, from sourceBase: StorageLocation, sourceSubfolders: [String]?, to targetBase: StorageLocation, targetSubfolders: [String]?)
    
    func moveFile(named fileName: String, from sourceBase: StorageLocation, sourceSubfolders: [String]?, to targetBase: StorageLocation, targetSubfolders: [String]?)
    
    func saveData(_ data: Data, named fileName: String, to base: StorageLocation, subfolders: [String]?)
    
    func readData(named fileName: String, from base: StorageLocation, subfolders: [String]?) -> Data?
}
