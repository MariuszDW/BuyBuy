//
//  CircleIconView.swift
//  BuyBuy
//
//  Created by MDW on 04/07/2025.
//

import SwiftUI

struct CircleIconView: View {
    let systemName: String
    var color: Color = Color.bb.accent
    
    @ScaledMetric(relativeTo: .body) private var size: CGFloat = 22
    private let iconScale: CGFloat = 0.6
    @Environment(\.isEnabled) private var isEnabled

    var body: some View {
        let iconColor = isEnabled ? color : Color(.systemGray3)
        let iconSize = size * iconScale

        ZStack {
            Circle()
                .strokeBorder(iconColor, lineWidth: 1.5)
                .frame(width: size, height: size)

            Image(systemName: systemName)
                .resizable()
                .scaledToFit()
                .frame(width: iconSize, height: iconSize)
                .foregroundColor(iconColor)
        }
        .frame(width: size, height: size)
    }
}
