//
//  MockFileStorage.swift
//  BuyBuy
//
//  Created by MDW on 16/06/2025.
//

import Foundation

final class MockFileStorage: FileStorageProtocol {
    func saveFile(data: Data, fileName: String) async throws {
    }
    
    func readFile(fileName: String) async throws -> Data {
        return Data()
    }
    
    func deleteFile(fileName: String) async throws {
    }
    
    func listFiles() async throws -> [String] {
        return ["file_1", "file_2"]
    }
}
