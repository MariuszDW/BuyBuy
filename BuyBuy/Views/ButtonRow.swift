//
//  ButtonRow.swift
//  BuyBuy
//
//  Created by MDW on 04/10/2025.
//

import SwiftUI

struct AdaptiveButton: View {
    let label: String?
    let systemImage: String?
    let highlight: Bool
    let badge: Int?
    let minWidth: CGFloat?
    let action: () -> Void
    
    init(label: String? = nil, systemImage: String? = nil, highlight: Bool = false, badge: Int? = nil, minWidth: CGFloat? = nil, action: @escaping () -> Void = {}) {
        self.label = label
        self.systemImage = systemImage
        self.highlight = highlight
        self.badge = badge
        self.minWidth = minWidth
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            contentView
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
        }
        .frame(minWidth: minWidth)
        .background(backgroundView)
        .overlay(
            Group {
                if let badge, badge > 0 {
                    Text("\(badge)")
                        .font(.boldDynamic(style: .footnote))
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Capsule().fill(.red))
                        .offset(x: 4, y: -8)
                }
            },
            alignment: .topTrailing
        )
    }
    
    @ViewBuilder
    private var contentView: some View {
        if let label, let systemImage {
            Label(label, systemImage: systemImage)
                .symbolRenderingMode(.monochrome)
                .font(.semiboldDynamic(style: .title3))
                .foregroundStyle(Color.bb.text.primary)
                .lineLimit(1)
        } else if let label {
            Text(label)
                .font(.semiboldDynamic(style: .title3))
                .foregroundStyle(Color.bb.text.primary)
                .lineLimit(1)
        } else if let systemImage {
            Image(systemName: systemImage)
                .font(.semiboldDynamic(style: .title3))
                .foregroundStyle(Color.bb.text.primary)
        }
    }
    
    @ViewBuilder
    private var backgroundView: some View {
        if #available(iOS 26, *) {
            Capsule()
                .fill(highlight ? Color.bb.selection.opacity(0.2) : Color.bb.background.opacity(0.6))
                .overlay(
                    Capsule()
                        .stroke(Color.bb.selection.opacity(highlight ? 1 : 0), lineWidth: 3)
                )
                .glassEffect(.clear.interactive(), in: .capsule)
                .shadow(color: Color.black.opacity(0.2), radius: 6, x: 0, y: 1)
        } else {
            Capsule()
                .fill(.ultraThinMaterial)
                .shadow(color: Color.black.opacity(0.2), radius: 6, x: 0, y: 1)
                .overlay(
                    Capsule()
                        .fill(highlight ? Color.bb.selection.opacity(0.2) : Color.bb.background.opacity(0.2))
                )
                .overlay(
                    Capsule()
                        .stroke(Color.bb.selection.opacity(highlight ? 1 : 0), lineWidth: 3)
                )
                .compositingGroup()
        }
    }
}

struct ButtonRow: View {
    let leftButtons: [AdaptiveButton]
    let rightButtons: [AdaptiveButton]
    
    init(leftButtons: [AdaptiveButton] = [], rightButtons: [AdaptiveButton] = []) {
        self.leftButtons = leftButtons
        self.rightButtons = rightButtons
    }

    var body: some View {
        HStack {
            HStack(spacing: 10) {
                ForEach(Array(leftButtons.enumerated()), id: \.offset) { _, button in
                    button
                }
            }
            Spacer()
            HStack(spacing: 10) {
                ForEach(Array(rightButtons.enumerated()), id: \.offset) { _, button in
                    button
                }
            }
        }
    }
}

// MARK: - Preview

#Preview("Light") {
    VStack {
        Spacer()
        ButtonRow(
            leftButtons: [
                AdaptiveButton(label: "Edit", systemImage: nil, badge: 123) { print("Edit tapped") },
                AdaptiveButton(label: "Add", systemImage: "plus.circle", highlight: true, badge: 3) { print("Plus tapped") }
            ],
            rightButtons: [
                AdaptiveButton(label: nil, systemImage: "hourglass", badge: 24, minWidth: 60) { print("Settings tapped") }
            ]
        )
        .padding(.horizontal)
        .padding(.bottom, 4)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.bb.background)
    .preferredColorScheme(.light)
}

#Preview("Dark") {
    VStack {
        Spacer()
        ButtonRow(
            leftButtons: [
                AdaptiveButton(label: "Edit", systemImage: nil, badge: 123) { print("Edit tapped") },
                AdaptiveButton(label: "Add", systemImage: "plus.circle", highlight: true, badge: 3) { print("Plus tapped") }
            ],
            rightButtons: [
                AdaptiveButton(label: nil, systemImage: "hourglass", badge: 24, minWidth: 80) { print("Settings tapped") }
            ]
        )
        .padding(.horizontal)
        .padding(.bottom, 4)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.bb.background)
    .preferredColorScheme(.dark)
}
