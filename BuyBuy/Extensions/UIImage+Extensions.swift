//
//  UIImage+Extensions.swift
//  BuyBuy
//
//  Created by MDW on 27/08/2025.
//

import Foundation
import SwiftUI

extension UIImage {
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
    
    func createThumbnail(size thumbnailSize: CGSize = CGSize(width: 64, height: 64)) async -> UIImage? {
        let originalSize = self.size
        let squareLength = min(originalSize.width, originalSize.height)
        
        let cropOriginX = (originalSize.width - squareLength) / 2
        let cropOriginY = (originalSize.height - squareLength) / 2
        let cropRect = CGRect(x: cropOriginX, y: cropOriginY, width: squareLength, height: squareLength)
        
        guard let cgImage = self.cgImage?.cropping(to: cropRect) else {
            return nil
        }
        
        let croppedImage = UIImage(cgImage: cgImage, scale: self.scale, orientation: self.imageOrientation)
        
        let renderer = UIGraphicsImageRenderer(size: thumbnailSize)
        let thumbnail = renderer.image { _ in
            croppedImage.draw(in: CGRect(origin: .zero, size: thumbnailSize))
        }
        
        return thumbnail
    }
}
