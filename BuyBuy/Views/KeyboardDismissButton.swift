//
//  KeyboardDismissButton.swift
//  BuyBuy
//
//  Created by MDW on 03/07/2025.
//

import SwiftUI

struct KeyboardDismissButton: View {
    let action: () -> Void

    var body: some View {
        HStack {
            Spacer()
            Button(action: action) {
                Image(systemName: "keyboard.chevron.compact.down")
                    .font(.regularDynamic(style: .title2))
                    .foregroundColor(.bb.selection)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.bb.background.opacity(0.5))
                    )
            }
        }
    }
}
