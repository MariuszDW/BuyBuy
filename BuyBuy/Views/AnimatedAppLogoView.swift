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
    
    private let encoreLogoImages = [
        Image.bbEncoreLogoE,
        Image.bbEncoreLogoN,
        Image.bbEncoreLogoC,
        Image.bbEncoreLogoO,
        Image.bbEncoreLogoR,
        Image.bbEncoreLogoE
    ]
    
    private let size: CGFloat
    private let tintedImages: [Image]

    init(size: CGFloat) {
        self.size = size
        self.tintedImages = encoreLogoImages.map { $0.renderingMode(.template) }
    }

    private var logoSize: CGFloat { size * 0.77 }

    private var shadowOffset: CGFloat { size * 0.006 }
    private var shadowRadius: CGFloat { logoSize * 0.025 }

    private var encoreCharSize: CGFloat { size * 0.1 }
    private var encoreCharKerning: CGFloat { encoreLogoSpacing * size * 0.04 }
    private var encoreLogoPosition: CGPoint { CGPoint(x: size * 0.5, y: size * 0.9) }
    
    private var copyrightPosition: CGPoint { CGPoint(x: size * 0.35, y: size * 0.8) }

    var body: some View {
        ZStack {
            // encore logo
            HStack(spacing: encoreCharKerning) {
                ForEach(0..<tintedImages.count, id: \.self) { index in
                    tintedImages[index]
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.bb.text.primary)
                        .frame(height: encoreCharSize)
                        .opacity(encoreLogoOpacity)
                }
            }
            .position(encoreLogoPosition)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation(.easeInOut(duration: 3.5)) {
                        encoreLogoSpacing = 0.0
                        encoreLogoOpacity = 0.3
                    }
                }
            }

            // copyright
            Text("copyright_year")
                .font(.system(size: size * 0.055, weight: .bold))
                .foregroundColor(.bb.text.primary.opacity(encoreLogoOpacity))
                .position(copyrightPosition)

            // Buy logo 1
            Image.bbBuyBuyLogo
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: logoSize, height: logoSize)
                .offset(
                    x: logoSize * -0.08,
                    y: logoSize * -0.26
                )
                .shadow(
                    color: .black.opacity(0.5),
                    radius: shadowRadius,
                    x: shadowOffset,
                    y: shadowOffset
                )
                .opacity(logo1Opacity)
                .scaleEffect(logo1Scale)
                .onAppear {
                    withAnimation(.spring(response: 0.7, dampingFraction: 0.3)) {
                        logo1Opacity = 1.0
                        logo1Scale = 1.0
                    }

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.3)) {
                            logo2Opacity = 1.0
                            logo2Scale = 1.0
                        }
                    }
                }

            // Buy logo 2
            Image.bbBuyBuyLogo
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: logoSize, height: logoSize)
                .offset(
                    x: logoSize * 0.08,
                    y: logoSize * 0.09
                )
                .shadow(
                    color: .black.opacity(0.6),
                    radius: shadowRadius,
                    x: shadowOffset,
                    y: shadowOffset
                )
                .opacity(logo2Opacity)
                .scaleEffect(logo2Scale)
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Preview

#Preview("Light") {
    NavigationStack {
        GeometryReader { geo in
            let size = geo.size.width

            AnimatedAppLogoView(size: size)
                .frame(width: size, height: size)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    .preferredColorScheme(.light)
}

#Preview("Dark") {
    NavigationStack {
        GeometryReader { geo in
            let size = geo.size.width

            AnimatedAppLogoView(size: size)
                .frame(width: size, height: size)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    .preferredColorScheme(.dark)
}
