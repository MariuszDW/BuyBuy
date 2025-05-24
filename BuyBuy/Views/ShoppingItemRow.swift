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
    let onRowTap: (ShoppingItem) -> Void // TODO: Klikanie na calym row chyba jednak nie powinno pokazywac detali itema.
    
    var body: some View {
        HStack(alignment: .top) {
            if !disabled {
                Button {
                    onToggleStatus(item)
                } label: {
                    item.status.checkBoxImage
                        .foregroundColor(.bb.selection)
                        .font(.regularDynamic(style: .headline))
                        .scaleEffect(1.5)
                }
                .buttonStyle(.plain)
                .padding(.trailing, 8)
            }
            
            Button {
                onRowTap(item)
            } label: {
                HStack {
                    VStack(alignment: .leading) {
                        Text(item.name)
                            .foregroundColor(.bb.text.primary)
                            .font(.regularDynamic(style: .headline))
                            .multilineTextAlignment(.leading)
                            .lineLimit(5)
                        if !item.note.isEmpty {
                            Text(item.note)
                                .foregroundColor(.bb.text.secondary)
                                .font(.regularDynamic(style: .subheadline))
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

#Preview("Light") {
    let item = ShoppingItem(id: UUID(), order: 0, listID: UUID(), name: "Milk Pilos",
                            note: "3.2% 1L", status: .pending)
    
    ZStack {
        ShoppingItemRow(item: item, disabled: false, onToggleStatus: {_ in }, onRowTap: {_ in })
            .padding(12)
            .background(Color(.systemBackground))
            .padding(16)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.gray)
    .preferredColorScheme(.light)
}

#Preview("Dark") {
    let item = ShoppingItem(id: UUID(), order: 0, listID: UUID(), name: "Milk Pilos",
                            note: "3.2% 1L", status: .pending)
    
    ZStack {
        ShoppingItemRow(item: item, disabled: false, onToggleStatus: {_ in }, onRowTap: {_ in })
            .padding(12)
            .background(Color(.systemBackground))
            .padding(16)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.gray)
    .preferredColorScheme(.dark)
}
