//
//  CapsuleButton.swift
//  BuyBuy
//
//  Created by MDW on 09/11/2025.
//

import SwiftUI

struct CapsuleButton: View {
    let title: String?
    let systemImage: String?
    let badge: Int?
    let badgeColor: Color?
    let minWidth: CGFloat?
    let highlighted: Bool
    let action: () -> Void

    init(
        _ title: String? = nil,
        systemImage: String? = nil,
        badge: Int? = nil,
        badgeColor: Color? = nil,
        minWidth: CGFloat? = nil,
        highlighted: Bool = false,
        action: @escaping () -> Void = {}
    ) {
        self.title = title
        self.systemImage = systemImage
        self.badge = badge
        self.badgeColor = badgeColor
        self.minWidth = minWidth
        self.highlighted = highlighted
        self.action = action
    }
    
    var body: some View {
        let button = Button(action: action) {
            content
                .padding(.horizontal, 4)
                .padding(.vertical, 4)
                .frame(minWidth: minWidth)
        }
        
        button
            .glassButtonStyle(highlighted: highlighted)
            .overlay(badgeView, alignment: .topTrailing)
    }

    @ViewBuilder
    private var content: some View {
        if let title, let systemImage {
            Label(title, systemImage: systemImage)
                .font(.semiboldDynamic(style: .title3))
                .symbolRenderingMode(.hierarchical)
                .lineLimit(1)
        } else if let systemImage {
            Image(systemName: systemImage)
                .font(.semiboldDynamic(style: .title3))
                .symbolRenderingMode(.hierarchical)
        } else if let title {
            Text(title)
                .font(.semiboldDynamic(style: .title3))
                .lineLimit(1)
        } else {
            EmptyView()
        }
    }

    @ViewBuilder
    private var badgeView: some View {
        if let badge, badge > 0 {
            Text("\(badge)")
                .font(.boldDynamic(style: .caption))
                .foregroundColor(.white)
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(
                    AdaptiveBadgeShape()
                        .fill(badgeColor ?? .red)
                )
                .overlay(
                    AdaptiveBadgeShape()
                        .stroke(.white, lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.15), radius: 2, y: 2)
                .fixedSize()
                .offset(x: 5, y: -6)
        }
    }
}

private struct AdaptiveBadgeShape: Shape {
    func path(in rect: CGRect) -> Path {
        if rect.width <= rect.height {
            return Circle().path(in: rect)
        } else {
            return Capsule().path(in: rect)
        }
    }
}

struct LegacyCapsuleGlassStyle: ButtonStyle {
    let highlighted: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(6)
            .background(
                Capsule()
                    .fill(
                        highlighted
                        ? AnyShapeStyle(Color.bb.accent.opacity(0.3))
                        : AnyShapeStyle(.ultraThinMaterial)
                    )
            )
            .shadow(color: .black.opacity(0.2), radius: 5, y: 2)
            .scaleEffect(configuration.isPressed ? 1.1 : 1.0)
            .brightness(configuration.isPressed ? -0.02 : 0)
            .animation(
                .spring(response: 0.3, dampingFraction: 0.3, blendDuration: 0.2),
                value: configuration.isPressed
            )
    }
}

extension View {
    @ViewBuilder
    func glassButtonStyle(highlighted: Bool) -> some View {
        if #available(iOS 26.0, *) {
            if highlighted {
                self.buttonStyle(.glassProminent)
                    .tint(Color.bb.accent.opacity(0.8))
            } else {
                self.buttonStyle(.glass)
            }
        } else {
            self.buttonStyle(LegacyCapsuleGlassStyle(highlighted: highlighted))
                .foregroundStyle(Color.bb.text.primary)
        }
    }
}

// MARK: - Preview

#Preview("Light") {
    VStack(spacing: 32) {
        CapsuleButton("Add", systemImage: "plus", badge: 3, badgeColor: .green) { }
        CapsuleButton("Edit") { }
        CapsuleButton(systemImage: "heart", badge: 12, badgeColor: .blue, minWidth: 56) { }
        CapsuleButton("Settings", systemImage: "gearshape", badge: 769, highlighted: true) { }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .preferredColorScheme(.light)
}

#Preview("Dark") {
    VStack(spacing: 32) {
        CapsuleButton("Add", systemImage: "plus", badge: 3, badgeColor: .green) { }
        CapsuleButton("Edit") { }
        CapsuleButton(systemImage: "heart", badge: 12, badgeColor: .blue, minWidth: 56) { }
        CapsuleButton("Settings", systemImage: "gearshape", badge: 769, highlighted: true) { }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .preferredColorScheme(.dark)
}
