//
//  BottomPanelView.swift
//  BuyBuy
//
//  Created by MDW on 08/06/2025.
//

import SwiftUI

struct BottomPanelView: View {
    let title: String
    let systemImage: String
    let isButtonDisabled: Bool
    let action: () -> Void
    
    init(title: String, systemImage: String, isButtonDisabled: Bool = false, action: @escaping () -> Void) {
        self.title = title
        self.systemImage = systemImage
        self.isButtonDisabled = isButtonDisabled
        self.action = action
    }
    
    var body: some View {
        HStack {
            Button(action: action) {
                Label(title, systemImage: systemImage)
                    .font(.headline)
            }
            .disabled(isButtonDisabled)
            
            Spacer()
        }
        .padding()
        .background(Color.bb.background)
        .ignoresSafeArea(edges: .bottom)
        .overlay(alignment: .top) {
            LinearGradient(
                colors: [.bb.text.primary.opacity(0.0), .bb.text.primary.opacity(0.1)],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 5)
            .offset(y: -5)
            .allowsHitTesting(false)
        }
    }
}

// MARK: - Preview

#Preview("Light") {
    VStack {
        Spacer()
        BottomPanelView(
            title: "Add item",
            systemImage: "plus.circle",
            isButtonDisabled: false,
            action: { print("Add item button tapped") }
        )
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.bb.background2)
    .preferredColorScheme(.light)
}

#Preview("Dark") {
    VStack {
        Spacer()
        BottomPanelView(
            title: "Add item",
            systemImage: "plus.circle",
            isButtonDisabled: false,
            action: { print("Add item button tapped") }
        )
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.bb.background2)
    .preferredColorScheme(.dark)
}
