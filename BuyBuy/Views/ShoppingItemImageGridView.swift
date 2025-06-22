//
//  ShoppingItemImageGridView.swift
//  BuyBuy
//
//  Created by MDW on 27/05/2025.
//

import SwiftUI

struct ShoppingItemImageGridView: View {
    let images: [UIImage?]
    var onUserInteraction: () -> Void
    var onAddImage: (UIImage) -> Void
    var onTapImage: (Int) -> Void
    var onDeleteImage: (Int) -> Void
    
    static let itemSize: CGFloat = 64
    static let itemCornerRadius: CGFloat = 8
    static let itemSpacing: CGFloat = 12
    static let selectionLineWidth: CGFloat = 4
    
    @State private var showingActionsForIndex: Int? = nil
    @State private var showImageSourceSheet = false
    
    private let columns = [
        GridItem(.adaptive(minimum: Self.itemSize), spacing: Self.itemSpacing)
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, alignment: .leading, spacing: Self.itemSpacing) {
            ForEach(images.indices, id: \.self) { index in
                imageView(with: images[index])
                    .clipShape(RoundedRectangle(cornerRadius: Self.itemCornerRadius))
                    .overlay {
                        if showingActionsForIndex == index {
                            RoundedRectangle(cornerRadius: Self.itemCornerRadius)
                                .stroke(Color.bb.selection, lineWidth: Self.selectionLineWidth)
                        }
                    }
                    .contentShape(Rectangle())
                    .popover(isPresented: Binding(
                        get: {
                            showingActionsForIndex == index
                        },
                        set: { newValue in
                            if !newValue {
                                showingActionsForIndex = nil
                            }
                        })
                    ) {
                        imageActionMenu
                            .presentationCompactAdaptation(.popover)
                    }
                    .onTapGesture {
                        onUserInteraction()
                        onTapImage(index)
                    }
                    .onLongPressGesture {
                        onUserInteraction()
                        showingActionsForIndex = index
                    }
            }
            
            Button(action: {
                onUserInteraction()
                showImageSourceSheet = true
            }) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 30, weight: .medium))
                    .foregroundColor(.bb.text.secondary)
                    .frame(width: Self.itemSize, height: Self.itemSize)
                    .background(Color.bb.sheet.background)
                    .cornerRadius(Self.itemCornerRadius)
            }
            .buttonStyle(.plain)
            .contentShape(Rectangle())
            .popover(isPresented: $showImageSourceSheet, attachmentAnchor: .rect(.bounds), arrowEdge: .bottom) {
                ImageSourcePickerView { image in
                    if let image = image {
                        onAddImage(image)
                    }
                }
                .presentationCompactAdaptation(.popover)
            }
        }
    }
    
    @ViewBuilder
    private func imageView(with uiImage: UIImage?) -> some View {
        if let uiImage = uiImage {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .frame(width: Self.itemSize, height: Self.itemSize)
        } else {
            let config = UIImage.SymbolConfiguration(pointSize: Self.itemSize, weight: .regular)
            let image = UIImage(systemName: "questionmark.circle",
                                withConfiguration: config)?.withRenderingMode(.alwaysTemplate)
            Image(uiImage: image ?? UIImage())
                .resizable()
                .scaledToFit()
                .padding(8)
                .frame(width: Self.itemSize, height: Self.itemSize)
                .background(Color.bb.background2)
                .foregroundColor(.bb.text.tertiary)
                .clipShape(RoundedRectangle(cornerRadius: Self.itemCornerRadius))
                .overlay(
                    RoundedRectangle(cornerRadius: Self.itemCornerRadius)
                        .stroke(Color.bb.text.tertiary, lineWidth: 1)
                )
        }
    }
    
    private var imageActionMenu: some View {
        VStack(alignment: .leading, spacing: 24) {
            Button {
                if let index = showingActionsForIndex {
                    onTapImage(index)
                    showingActionsForIndex = nil
                }
            } label: {
                HStack {
                    Text("view_image")
                    Spacer()
                    Image(systemName: "eye")
                }
                .foregroundColor(.bb.selection)
            }
            
            Button {
                if let index = showingActionsForIndex {
                    onDeleteImage(index)
                    showingActionsForIndex = nil
                }
            } label: {
                HStack {
                    Text("delete")
                    Spacer()
                    Image(systemName: "trash")
                }
                .foregroundColor(.bb.destructive)
            }
        }
        .padding()
    }
}

// MARK: - Preview

@MainActor
final class ShoppingItemImageGridViewMocks {
    static let mockImage1 = MockImageStorage.generateMockImage(
        text: "TEST IMAGE 1",
        size: CGSize(width: 100, height: 100),
        backgroundColor: UIColor.yellow,
        textColor: UIColor.gray
    )
    
    static let mockImage2 = MockImageStorage.generateMockImage(
        text: "TEST IMAGE 2",
        size: CGSize(width: 100, height: 100),
        backgroundColor: UIColor.green,
        textColor: UIColor.black
    )
    
    static let mockImage3 = MockImageStorage.generateMockImage(
        text: "TEST IMAGE 3",
        size: CGSize(width: 100, height: 100),
        backgroundColor: UIColor.red,
        textColor: UIColor.white
    )

    static let mockImages = [
        mockImage1, mockImage2, mockImage3, nil, mockImage2, nil, mockImage1, mockImage2, mockImage3
    ]
}


#Preview("Light") {
    ShoppingItemImageGridView(images: ShoppingItemImageGridViewMocks.mockImages, onUserInteraction: {},
                              onAddImage: {_ in}, onTapImage: {_ in}, onDeleteImage: {_ in})
    .padding()
    .preferredColorScheme(.light)
}

#Preview("Dark") {
    ShoppingItemImageGridView(images: ShoppingItemImageGridViewMocks.mockImages, onUserInteraction: {},
                              onAddImage: {_ in}, onTapImage: {_ in}, onDeleteImage: {_ in})
    .padding()
    .preferredColorScheme(.dark)
}
