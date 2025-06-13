//
//  AnimatedAppLogoView.swift
//  BuyBuy
//
//  Created by MDW on 12/06/2025.
//

import SwiftUI

struct AnimatedAppLogoView: View {
    @State private var logo1Opacity: Double = 0.0
    @State private var logo1Scale: CGFloat = 0.1
    @State private var logo2Opacity: Double = 0.0
    @State private var logo2Scale: CGFloat = 0.1
    @State private var encoreLogoSpacing: CGFloat = 2.0
    @State private var encoreLogoOpacity: CGFloat = 0.0
    @State private var copyrightPosX: CGFloat = 0.0
    
    private let tintedImages: [Image]
    
    private let encoreLogoImages = [
        Image.bbEncoreLogoE,
        Image.bbEncoreLogoN,
        Image.bbEncoreLogoC,
        Image.bbEncoreLogoO,
        Image.bbEncoreLogoR,
        Image.bbEncoreLogoE
    ]
    
    init() {
        self.tintedImages = encoreLogoImages.map { $0.renderingMode(.template) }
    }
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let logoSize = width * 0.77
            let halfLogoSize = logoSize * 0.5
            let logo1Offset: CGPoint = CGPoint(x: logoSize * 0.06 + halfLogoSize, y: logoSize * -0.11 + halfLogoSize)
            let logo2Offset: CGPoint = CGPoint(x: logoSize * 0.22 + halfLogoSize, y: logoSize * 0.25 + halfLogoSize)
            let shadowOffset = width * 0.006
            let shadowRadius = CGFloat(logoSize * 0.025)
            let encoreCharSize = CGFloat(width * 0.1)
            let encoreCharKerning = CGFloat(encoreLogoSpacing * width * 0.04)
            let encoreLogoPos = CGPoint(x: 0, y: width * 0.87)
            let copyrightPosY = CGFloat(width * 0.8)
            let copyrightFontSize = width * 0.055

            ZStack(alignment: .topLeading) {
                HStack(alignment: .center, spacing: encoreCharKerning) {
                    ForEach(0..<tintedImages.count, id: \.self) { index in
                        tintedImages[index]
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.bb.text.primary)
                            .frame(height: encoreCharSize)
                            .opacity(encoreLogoOpacity)
                    }
                }
                .offset(x: encoreLogoPos.x, y: encoreLogoPos.y)
                .frame(maxWidth: .infinity, alignment: .center)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        withAnimation(.easeInOut(duration: 3.5)) {
                            encoreLogoSpacing = 0.0
                            encoreLogoOpacity = 0.3
                            copyrightPosX = 0.18
                        }
                    }
                }
                
                Text("© 2025")
                    .offset(x: width * copyrightPosX, y: copyrightPosY)
                    .foregroundColor(.bb.text.primary.opacity(encoreLogoOpacity))
                    .font(.system(size: copyrightFontSize, weight: .bold))
                
                Image.bbBuyBuyLogo
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: logoSize, height: logoSize)
                    .offset(x: logo1Offset.x - (logoSize / 2), y: logo1Offset.y - (logoSize / 2))
                    .shadow(color: Color.black.opacity(0.5), radius: shadowRadius, x: shadowOffset, y: shadowOffset)
                    .opacity(logo1Opacity)
                    .scaleEffect(logo1Scale, anchor: .center)
                    .onAppear {
                        withAnimation(.spring(response: 0.7, dampingFraction: 0.3, blendDuration: 0)) {
                            logo1Opacity = 1.0
                            logo1Scale = 1.0
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.3, blendDuration: 0)) {
                                logo2Opacity = 1.0
                                logo2Scale = 1.0
                            }
                        }
                    }

                Image.bbBuyBuyLogo
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: logoSize, height: logoSize)
                    .offset(x: logo2Offset.x - (logoSize / 2), y: logo2Offset.y - (logoSize / 2))
                    .shadow(color: Color.black.opacity(0.6), radius: shadowRadius, x: shadowOffset, y: shadowOffset)
                    .opacity(logo2Opacity)
                    .scaleEffect(logo2Scale, anchor: .center)
            }
            .frame(width: width, height: geometry.size.height, alignment: .topLeading)
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

// MARK: - Preview

#Preview("Light") {
    NavigationStack {
        AnimatedAppLogoView()
    }
    .preferredColorScheme(.light)
}

#Preview("Dark") {
    NavigationStack {
        AnimatedAppLogoView()
    }
    .preferredColorScheme(.dark)
}
