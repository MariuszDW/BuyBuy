//
//  BBPlainButtonStyle.swift
//  BuyBuy
//
//  Created by MDW on 01/07/2025.
//

import SwiftUI

struct BBPlainButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.semiboldDynamic(style: .callout))
            .foregroundColor(.bb.button.text)
            .frame(minWidth: 100)
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.bb.button.background)
            )
            .opacity(configuration.isPressed ? 0.7 : 1.0)
    }
}
