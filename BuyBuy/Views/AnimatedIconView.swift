//
//  AnimatedIconView.swift
//  BuyBuy
//
//  Created by MDW on 24/05/2025.
//

import SwiftUI

struct AnimatedIconView: View {
    let image: Image
    let color: Color
    let size: CGFloat
    let response: Double
    let dampingFraction: Double
    
    @State private var animate = false

    var body: some View {
        image
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
            .foregroundColor(color)
            .scaleEffect(animate ? 1 : 0.1)
            .opacity(animate ? 1 : 0)
            .animation(.spring(response: response, dampingFraction: dampingFraction), value: animate)
            .onAppear {
                animate = true
            }
            .onDisappear {
                animate = false
            }
    }
}

#Preview("Light") {
    AnimatedIconView(
        image: Image(systemName: "list.bullet.circle.fill"),
        color: .gray,
        size: 200,
        response: 0.9,
        dampingFraction: 0.3
    )
    .padding()
    .preferredColorScheme(.light)
}

#Preview("Dark") {
    AnimatedIconView(
        image: Image(systemName: "list.bullet.circle.fill"),
        color: .gray,
        size: 200,
        response: 0.9,
        dampingFraction: 0.3
    )
    .padding()
    .preferredColorScheme(.dark)
}
