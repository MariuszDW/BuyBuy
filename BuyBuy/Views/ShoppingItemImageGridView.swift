//
//  ShoppingItemImageGridView.swift
//  BuyBuy
//
//  Created by MDW on 27/05/2025.
//

import SwiftUI
import UIKit

struct ShoppingItemImageGridView: View {
    let images: [UIImage]
    var onAddImage: () -> Void
    var onTapImage: (Int) -> Void

    private let columns = [
        GridItem(.adaptive(minimum: 64), spacing: 12)
    ]

    var body: some View {
        LazyVGrid(columns: columns, alignment: .leading, spacing: 12) {
            ForEach(images.indices, id: \.self) { index in
                Button {
                    onTapImage(index)
                } label: {
                    Image(uiImage: images[index])
                        .resizable()
                        .scaledToFill()
                        .frame(width: 64, height: 64)
                        .clipped()
                        .cornerRadius(8)
                }
                .buttonStyle(.plain)
            }

            Button(action: onAddImage) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 30, weight: .medium))
                    .foregroundColor(.bb.text.secondary)
                    .frame(width: 64, height: 64)
                    .background(Color.bb.sheet.background)
                    .cornerRadius(8)
            }
            .buttonStyle(.plain)
            .contentShape(Rectangle())
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Preview

let mockImage1 = MockImageStorageService.generateMockImage(text: "TEST IMAGE 1", size: CGSize(width: 100, height: 100), backgroundColor: UIColor.yellow, textColor: UIColor.gray)
let mockImage2 = MockImageStorageService.generateMockImage(text: "TEST IMAGE 2", size: CGSize(width: 100, height: 100), backgroundColor: UIColor.green, textColor: UIColor.black)
let mockImage3 = MockImageStorageService.generateMockImage(text: "TEST IMAGE 3", size: CGSize(width: 100, height: 100), backgroundColor: UIColor.red, textColor: UIColor.white)

let mockImages = [mockImage1, mockImage2, mockImage3, mockImage1, mockImage2, mockImage3, mockImage1, mockImage2, mockImage3]

#Preview("Light") {
    ShoppingItemImageGridView(images: mockImages, onAddImage: {}, onTapImage: {_ in})
        .padding()
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    ShoppingItemImageGridView(images: mockImages, onAddImage: {}, onTapImage: {_ in})
        .padding()
        .preferredColorScheme(.dark)
}
