//
//  ImageStorageProtocol.swift
//  BuyBuy
//
//  Created by MDW on 28/05/2025.
//

import SwiftUI

protocol ImageStorageProtocol: Sendable {
    func cleanCache() async
    func save(image: UIImage, baseFileName: String, type: ImageType, cloud: Bool) async throws
    func save(data: Data, baseFileName: String, type: ImageType, cloud: Bool) async throws
    func loadImage(baseFileName: String, type: ImageType, cloud: Bool) async throws -> UIImage?
    func deleteImage(baseFileName: String, type: ImageType, cloud: Bool) async throws
    func deleteImage(baseFileName: String, types: [ImageType], cloud: Bool) async throws
    func listImageBaseNames(type: ImageType, cloud: Bool) async throws -> Set<String>
}
