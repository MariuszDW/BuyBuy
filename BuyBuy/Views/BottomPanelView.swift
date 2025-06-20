//
//  BottomPanelView.swift
//  BuyBuy
//
//  Created by MDW on 08/06/2025.
//

import SwiftUI

struct BottomPanelView<TrailingView: View>: View {
    let title: String
    let systemImage: String
    let isButtonDisabled: Bool
    let action: () -> Void
    let trailingView: TrailingView?
    
    init(title: String,
         systemImage: String,
         isButtonDisabled: Bool = false,
         @ViewBuilder trailingView: () -> TrailingView? = { nil },
         action: @escaping () -> Void
    ) {
        self.title = title
        self.systemImage = systemImage
        self.isButtonDisabled = isButtonDisabled
        self.trailingView = trailingView()
        self.action = action
    }
    
    var body: some View {
        HStack {
            Button(action: action) {
                Label(title, systemImage: systemImage)
                    .font(.boldDynamic(style: .headline))
                    .lineLimit(1)
            }
            .padding(.vertical, 16)
            .disabled(isButtonDisabled)
            
            Spacer(minLength: 16)
            
            if let trailingView = trailingView {
                trailingView
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 0)
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
            trailingView: { EmptyView() },
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
            trailingView: { EmptyView() },
            action: { print("Add item button tapped") }
        )
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.bb.background2)
    .preferredColorScheme(.dark)
}
