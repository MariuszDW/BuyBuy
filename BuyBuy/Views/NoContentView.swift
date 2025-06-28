//
//  NoContentView.swift
//  BuyBuy
//
//  Created by MDW on 28/06/2025.
//

import SwiftUI

struct NoContnetView: View {
    let title: String
    let message: String
    let image: Image
    let color: Color
    
    var body: some View {
        GeometryReader { geometry in
            Group {
                if geometry.size.isPortrait {
                    VStack() {
                        Spacer()
                        Spacer()
                        noContnetImageView(containerSize: geometry.size)
                        Spacer(minLength: 64)
                        VStack(spacing: 32) {
                            noContnetTitleView()
                            noContnetMessageView()
                        }
                        Spacer()
                        Spacer()
                    }
                } else {
                    HStack {
                        Spacer(minLength: 32)
                        noContnetImageView(containerSize: geometry.size)
                        Spacer(minLength: 32)
                        VStack(alignment: .leading, spacing: 24) {
                            noContnetTitleView(landscape: true)
                            noContnetMessageView(landscape: true)
                        }
                        Spacer(minLength: 32)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .position(x: geometry.size.width * 0.5, y: geometry.size.height * 0.5)
        }
        .padding(.horizontal, 32)
        .padding(.vertical, 40)
    }
    
    func noContnetImageView(containerSize: CGSize) -> some View {
        let imageSize = min(containerSize.shorterSide * 0.55, containerSize.longerSide * 0.4)
        return AnimatedIconView(
            image: image,
            color: color.opacity(0.5),
            size: imageSize,
            response: 0.8,
            dampingFraction: 0.3
        )
    }
    
    func noContnetTitleView(landscape: Bool = false) -> some View {
        Text(title)
            .font(.boldDynamic(style: .title2))
            .foregroundColor(.bb.text.tertiary)
            .multilineTextAlignment(landscape ? .leading : .center)
    }
    
    func noContnetMessageView(landscape: Bool = false) -> some View {
        Text(message)
            .font(.boldDynamic(style: .headline))
            .foregroundColor(.bb.text.tertiary)
            .multilineTextAlignment(landscape ? .leading : .center)
    }
}

#Preview("Light") {
    NoContnetView(
        title: "Empty test list.",
        message: "Use \"Add\" button to add your first element of the list.",
        image: Image(systemName: "list.bullet.circle.fill"),
        color: .red
    )
    .frame(width: .infinity, height: .infinity)
    .preferredColorScheme(.light)
}

#Preview("Dark") {
    NoContnetView(
        title: "Empty test list.",
        message: "Use \"Add\" button to add your first element of the list.",
        image: Image(systemName: "list.bullet.circle.fill"),
        color: .green
    )
    .preferredColorScheme(.dark)
}
