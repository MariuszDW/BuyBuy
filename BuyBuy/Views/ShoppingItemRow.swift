//
//  ShoppingItemRow.swift
//  BuyBuy
//
//  Created by MDW on 19/05/2025.
//

import SwiftUI

struct ShoppingItemRow: View {
    let item: ShoppingItem
    let disabled: Bool
    let onToggleStatus: (ShoppingItem) -> Void

    var body: some View {
        HStack {
            Button {
                onToggleStatus(item)
            } label: {
                Image(systemName: item.status.iconName)
                    .foregroundColor(.bbSelection)
                    .font(.title2)
            }
            .buttonStyle(.plain)
            .disabled(disabled)
            
            Text(item.name)
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}
