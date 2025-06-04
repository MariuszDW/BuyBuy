//
//  LoyaltyCardTileView.swift
//  BuyBuy
//
//  Created by MDW on 02/06/2025.
//

import SwiftUI

struct LoyaltyCardTileView: View {
    let id: UUID
    let name: String
    let thumbnail: UIImage?
    let tileWidth: CGFloat
    let selected: Bool
    
    private var strokeLineWidth: CGFloat {
        selected ? 4 : 2
    }
    
    private var strokeLineColor: Color {
        selected ? .bb.selection : .bb.text.tertiary
    }
    
    static let cornderRadius: CGFloat = 12
    
    var body: some View {
        VStack(alignment: .center, spacing: 6) {
            ZStack {
                if let image = thumbnail {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .clipped()
                } else {
                    Image(systemName: "creditcard.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: tileWidth * 0.65, height: tileWidth * 0.65)
                        .foregroundColor(.bb.text.quaternary)
                }
            }
            .frame(width: tileWidth, height: tileWidth)
            .background(Color.bb.background2)
            .cornerRadius(Self.cornderRadius)
            .contentShape(Rectangle())
            .clipShape(RoundedRectangle(cornerRadius: Self.cornderRadius))
            .shadow(color: Color.black.opacity(0.4), radius: 5, x: 0, y: 2)
            .overlay {
                RoundedRectangle(cornerRadius: Self.cornderRadius)
                    .stroke(strokeLineColor, lineWidth: strokeLineWidth)
            }

            Text(name)
                .font(.regularDynamic(style: .headline))
                .foregroundColor(.bb.text.primary)
                .lineLimit(3)
                .multilineTextAlignment(.center)
                .frame(width: tileWidth)
        }
        .frame(width: tileWidth, alignment: .top)
    }
}
