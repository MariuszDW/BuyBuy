//
//  ShoppingItemRow.swift
//  BuyBuy
//
//  Created by MDW on 19/05/2025.
//

import SwiftUI

struct ShoppingItemRow: View {
    let item: ShoppingItem
    let thumbnail: UIImage?
    let disabled: Bool
    let onToggleStatus: (UUID) -> Void
    let onRowTap: (UUID) -> Void
    let onThumbnailTap: (UUID, Int) -> Void
    
    var body: some View {
        HStack(alignment: .top) {
            if !disabled {
                statusCheckBox
                    .padding(.trailing, 8)
                    .padding(.bottom, 4)
            }
            
            mainContent
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
            
            thumbnailView
                .padding(.leading, 8)
        }
        .listRowInsets(EdgeInsets(top: 12, leading: 18, bottom: 8, trailing: 10))
    }
    
    @ViewBuilder
    private var thumbnailView: some View {
        let thumbnailCornerRadius: CGFloat = 6
        let thumbnailSize: CGFloat = 38
        
        Group {
            if let image = thumbnail {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: thumbnailSize, height: thumbnailSize)
                    .clipShape(RoundedRectangle(cornerRadius: thumbnailCornerRadius))
                    .overlay(
                        RoundedRectangle(cornerRadius: thumbnailCornerRadius)
                            .stroke(Color.bb.text.tertiary, lineWidth: 1)
                    )
            } else if !item.imageIDs.isEmpty{
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .padding(8)
                    .frame(width: thumbnailSize, height: thumbnailSize)
                    .background(Color.bb.background2)
                    .foregroundColor(.bb.text.tertiary)
                    .clipShape(RoundedRectangle(cornerRadius: thumbnailCornerRadius))
                    .overlay(
                        RoundedRectangle(cornerRadius: thumbnailCornerRadius)
                            .stroke(Color.bb.text.tertiary, lineWidth: 1)
                    )
            }
        }
        .onTapGesture {
            onThumbnailTap(item.id, 0)
        }
    }
    
    private var statusCheckBox: some View {
        Button {
            onToggleStatus(item.id)
        } label: {
            item.status.checkBoxImage
                .foregroundColor(.bb.selection)
                .font(.regularDynamic(style: .headline))
                .scaleEffect(1.5)
        }
        .buttonStyle(.plain)
    }
    
    private var mainContent: some View {
        Button {
            onRowTap(item.id)
        } label: {
            HStack {
                VStack(alignment: .leading) {
                    Text(item.name)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(.bb.text.primary)
                        .font(.regularDynamic(style: .headline))
                        .multilineTextAlignment(.leading)
                        .lineLimit(4)
                    
                    if !item.note.isEmpty {
                        Text(item.note)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundColor(.bb.text.secondary)
                            .font(.regularDynamic(style: .subheadline))
                            .multilineTextAlignment(.leading)
                            .lineLimit(6)
                    }
                    
                    quantityAndPrice
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.borderless)
    }
    
    @ViewBuilder
    private var quantityAndPrice: some View {
        if item.quantityWithUnit != nil || item.totalPrice != nil {
            HStack {
                if let quantityWithUnit = item.quantityWithUnit {
                    Text(quantityWithUnit)
                        .font(.regularDynamic(style: .callout))
                        .foregroundColor(.bb.text.highlightA)
                }
                Spacer()
                if let totalPrice = item.totalPrice {
                    Text(totalPrice.priceFormat)
                        .font(.regularMonospaced(style: .callout))
                        .foregroundColor(.bb.text.highlightB)
                }
            }
        }
    }
}

// MARK: - Preview

#Preview("Light") {
    let item = ShoppingItem(id: UUID(), order: 0, listID: UUID(), name: "Milk",
                            note: "Pilos 3.2%, promotion", status: .purchased,
                            price: 3.79, quantity: 6, unit: ShoppingItemUnit(.liter),
                            imageIDs: ["image_thumbnail"])
    
    List {
        ShoppingItemRow(item: item, thumbnail: UIImage(systemName: "image"),
                        disabled: false, onToggleStatus: {_ in },
                        onRowTap: {_ in }, onThumbnailTap: {_, _ in })
    }
    .listStyle(.plain)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.bb.background2)
    .preferredColorScheme(.light)
}

#Preview("Dark") {
    let item = ShoppingItem(id: UUID(), order: 0, listID: UUID(), name: "Milk",
                            note: "Pilos 3.2%, promotion", status: .purchased,
                            price: 3.79, quantity: 6, unit: ShoppingItemUnit(.liter),
                            imageIDs: ["image_thumbnail"])
    
    List {
        ShoppingItemRow(item: item, thumbnail: UIImage(systemName: "image"),
                        disabled: false, onToggleStatus: {_ in },
                        onRowTap: {_ in }, onThumbnailTap: {_, _ in })
    }
    .listStyle(.plain)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.bb.background2)
    .preferredColorScheme(.dark)
}

#Preview("Light/min") {
    let item = ShoppingItem(id: UUID(), order: 0, listID: UUID(), name: "Milk",
                            note: "", status: .purchased)
    
    List {
        ShoppingItemRow(item: item, thumbnail: UIImage(systemName: "image"),
                        disabled: false, onToggleStatus: {_ in },
                        onRowTap: {_ in }, onThumbnailTap: {_, _ in })
    }
    .listStyle(.plain)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.bb.background2)
    .preferredColorScheme(.light)
}

#Preview("Dark/min") {
    let item = ShoppingItem(id: UUID(), order: 0, listID: UUID(), name: "Milk",
                            note: "", status: .purchased)
    
    List {
        ShoppingItemRow(item: item, thumbnail: UIImage(systemName: "image"),
                        disabled: false, onToggleStatus: {_ in },
                        onRowTap: {_ in }, onThumbnailTap: {_, _ in })
    }
    .listStyle(.plain)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.bb.background2)
    .preferredColorScheme(.dark)
}
