//
//  MockImageStorage.swift
//  BuyBuy
//
//  Created by MDW on 28/05/2025.
//

import UIKit

actor MockImageStorage: ImageStorageProtocol {
    func clearThumbnailCache() async {}
    
    func saveItemImage(_ image: UIImage, baseFileName: String) async throws {}
    
    func saveItemThumbnail(for image: UIImage, baseFileName: String) async throws {}
    
    func saveItemImageAndThumbnail(_ image: UIImage, baseFileName: String) async throws {}
    
    func loadItemImage(baseFileName: String) async throws -> UIImage {
        return Self.generateMockImage(text: baseFileName, size: CGSize(width: 1024, height: 1024))
    }
    
    func loadItemThumbnail(baseFileName: String) async throws -> UIImage {
        return Self.generateMockImage(text: "\(baseFileName)_thumb", size: ImageStorageHelper.thumbnailSize)
    }
    
    func deleteItemImage(baseFileName: String) async throws {}
    
    func deleteItemThumbnail(baseFileName: String) async throws {}
    
    func deleteItemImageAndThumbnail(baseFileName: String) async throws {}
    
    func listAllItemImageBaseNames() async throws -> Set<String> {
        return Set<String>()
    }
    
    func saveCardImage(_ image: UIImage, baseFileName: String) async throws {}
    
    func saveCardThumbnail(for image: UIImage, baseFileName: String) async throws {}
    
    func saveCardImageAndThumbnail(_ image: UIImage, baseFileName: String) async throws {}
    
    func loadCardImage(baseFileName: String) async throws -> UIImage {
        return Self.generateMockImage(text: baseFileName, size: CGSize(width: 1024, height: 1024))
    }
    
    func loadCardThumbnail(baseFileName: String) async throws -> UIImage {
        return Self.generateMockImage(text: "\(baseFileName)_thumb", size: ImageStorageHelper.thumbnailSize)
    }
    
    func deleteCardImage(baseFileName: String) async throws {}
    
    func deleteCardThumbnail(baseFileName: String) async throws {}
    
    func deleteCardImageAndThumbnail(baseFileName: String) async throws {}
    
    func listAllCardImageBaseNames() async throws -> Set<String> {
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
