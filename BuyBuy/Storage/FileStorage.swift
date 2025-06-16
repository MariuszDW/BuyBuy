//
//  FileStorage.swift
//  BuyBuy
//
//  Created by MDW on 16/06/2025.
//

import Foundation

@MainActor
final class FileStorage: FileStorageProtocol {
    private let fileManager: FileManager
    private let documentsURL: URL
    
    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
        self.documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    func saveFile(data: Data, fileName: String) async throws {
        let fileURL = documentsURL.appendingPathComponent(fileName)
        try data.write(to: fileURL, options: .atomic)
    }
    
    func readFile(fileName: String) async throws -> Data {
        let fileURL = documentsURL.appendingPathComponent(fileName)
        return try Data(contentsOf: fileURL)
    }
    
    func deleteFile(fileName: String) async throws {
        let fileURL = documentsURL.appendingPathComponent(fileName)
        if fileManager.fileExists(atPath: fileURL.path) {
            try fileManager.removeItem(at: fileURL)
        }
    }
    
    func listFiles() async throws -> [String] {
        try fileManager.contentsOfDirectory(atPath: documentsURL.path)
    }
}
