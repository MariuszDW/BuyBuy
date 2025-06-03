//
//  ImageStorageProtocol.swift
//  BuyBuy
//
//  Created by MDW on 28/05/2025.
//

import SwiftUI

protocol ImageStorageProtocol: Sendable {
    func cleanCache() async
    func saveImage(_ image: UIImage, baseFileName: String, type: ImageType) async throws
    func loadImage(baseFileName: String, type: ImageType) async throws -> UIImage
    func deleteImage(baseFileName: String, type: ImageType) async throws
    func deleteImage(baseFileName: String, types: [ImageType]) async throws
    func listImageBaseNames(type: ImageType) async throws -> Set<String>
}
