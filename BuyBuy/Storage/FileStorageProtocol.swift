//
//  FileStorageProtocol.swift
//  BuyBuy
//
//  Created by MDW on 16/06/2025.
//

import Foundation

protocol FileStorageProtocol: Sendable {
    func saveFile(data: Data, fileName: String) async throws
    func readFile(fileName: String) async throws -> Data
    func deleteFile(fileName: String) async throws
    func listFiles() async throws -> [String]
}
