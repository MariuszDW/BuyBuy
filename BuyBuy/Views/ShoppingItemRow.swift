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
    let state: Bool?
    let onToggleStatus: (UUID) -> Void
    let onRowTap: (UUID) -> Void
    let onThumbnailTap: (UUID, Int) -> Void
    
    static private let thumbnailCornerRadius: CGFloat = 6
    static private let thumbnailSize: CGFloat = 38
    
    var body: some View {
        HStack(alignment: .top) {
            if let state = state {
                statusCheckBox(state: state)
                    .padding(.trailing, 8)
                    .padding(.bottom, 4)
            }
            
            mainContent
                .padding(.trailing, 8)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
            
            if !item.imageIDs.isEmpty {
                thumbnailView
                    .onTapGesture { onThumbnailTap(item.id, 0) }
            }
        }
        .listRowInsets(EdgeInsets(top: 12, leading: 18, bottom: 8, trailing: 10))
    }
    
    @ViewBuilder
    private var thumbnailView: some View {
        if let thumbnail = thumbnail {
            Image(uiImage: thumbnail)
                .resizable()
                .scaledToFill()
                .frame(width: Self.thumbnailSize, height: Self.thumbnailSize)
                .clipShape(RoundedRectangle(cornerRadius: Self.thumbnailCornerRadius))
                .overlay(
                    RoundedRectangle(cornerRadius: Self.thumbnailCornerRadius)
                        .stroke(Color.bb.text.tertiary, lineWidth: 1)
                )
        } else {
            let config = UIImage.SymbolConfiguration(pointSize: Self.thumbnailSize, weight: .regular)
            let image = UIImage(systemName: "questionmark.circle", withConfiguration: config)?.withRenderingMode(.alwaysTemplate)
            Image(uiImage: image ?? UIImage())
                .resizable()
                .scaledToFit()
                .padding(8)
                .frame(width: Self.thumbnailSize, height: Self.thumbnailSize)
                .background(Color.bb.background2)
                .foregroundColor(.bb.text.tertiary)
                .clipShape(RoundedRectangle(cornerRadius: Self.thumbnailCornerRadius))
                .overlay(
                    RoundedRectangle(cornerRadius: Self.thumbnailCornerRadius)
                        .stroke(Color.bb.text.tertiary, lineWidth: 1)
                )
        }
    }
    
    private func statusCheckBox(state: Bool) -> some View {
        Button {
            onToggleStatus(item.id)
        } label: {
            item.status.checkBoxImage
                .foregroundColor(state == true ? .bb.selection : .bb.text.quaternary)
                .font(.regularDynamic(style: .headline))
                .scaleEffect(1.5)
                .disabled(state == false)
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
                        .padding(.trailing, item.imageIDs.count > 0 ? 0 : Self.thumbnailSize)
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
                        state: true, onToggleStatus: {_ in },
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
                        state: true, onToggleStatus: {_ in },
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
                        state: true, onToggleStatus: {_ in },
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
                        state: true, onToggleStatus: {_ in },
                        onRowTap: {_ in }, onThumbnailTap: {_, _ in })
    }
    .listStyle(.plain)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.bb.background2)
    .preferredColorScheme(.dark)
}
