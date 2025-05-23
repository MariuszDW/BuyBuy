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
    let onRowTap: (ShoppingItem) -> Void
    
    var body: some View {
        HStack(alignment: .top) {
            if !disabled {
                Button {
                    onToggleStatus(item)
                } label: {
                    item.status.checkBoxImage
                        .foregroundColor(.bb.selection)
                        .font(.headline)
                }
                .buttonStyle(.plain)
            }
            
            Button {
                onRowTap(item)
            } label: {
                HStack {
                    VStack(alignment: .leading) {
                        Text(item.name)
                            .foregroundColor(.bb.text.primary)
                            .font(.headline)
                            .multilineTextAlignment(.leading)
                            .lineLimit(5)
                        if let note = item.note {
                            Text(note)
                                .foregroundColor(.bb.text.secondary)
                                .font(.subheadline)
                                .multilineTextAlignment(.leading)
                                .lineLimit(8)
                        }
                    }
                    
                    Spacer()
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.borderless)
        }
    }
}
