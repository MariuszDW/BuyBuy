//
//  MockImageStorage.swift
//  BuyBuy
//
//  Created by MDW on 28/05/2025.
//

import SwiftUI

actor MockImageStorage: ImageStorageProtocol {
    func cleanCache() async {}
    
    func saveImage(_ image: UIImage, baseFileName: String, type: ImageType) async throws {}
    
    func loadImage(baseFileName: String, type: ImageType) async throws -> UIImage {
        if type.isThumbnail {
            return Self.generateMockImage(text: "\(baseFileName)_thumb", size: ImageStorageHelper.thumbnailSize)
        } else {
            return Self.generateMockImage(text: baseFileName, size: CGSize(width: 1024, height: 1024))
        }
    }
    
    func deleteImage(baseFileName: String, type: ImageType) async throws {}
    
    func deleteImage(baseFileName: String, types: [ImageType]) async throws {}
    
    func listImageBaseNames(type: ImageType) async throws -> Set<String> {
        return Set<String>()
    }
    
    // MARK: - Helpers
    
    static func generateMockImage(text: String, size: CGSize,
                                  backgroundColor: UIColor = .systemGray5,
                                  textColor: UIColor = .gray) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            backgroundColor.setFill()
            context.fill(CGRect(origin: .zero, size: size))
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            
            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 18, weight: .medium),
                .foregroundColor: textColor,
                .paragraphStyle: paragraphStyle
            ]
            
            let attributedString = NSAttributedString(string: text, attributes: attrs)
            attributedString.draw(in: CGRect(origin: .zero, size: size).insetBy(dx: 10, dy: 10))
        }
    }
}
