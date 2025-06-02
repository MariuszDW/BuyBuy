//
//  ShoppingItemImageGridView.swift
//  BuyBuy
//
//  Created by MDW on 27/05/2025.
//

import SwiftUI

struct ShoppingItemImageGridView: View {
    let images: [UIImage]
    var onUserInteraction: () -> Void
    var onAddImage: (UIImage) -> Void
    var onTapImage: (Int) -> Void
    var onDeleteImage: (Int) -> Void
    
    static let itemSize: CGFloat = 64
    static let itemCornerRadius: CGFloat = 8
    static let itemSpacing: CGFloat = 12
    static let selectionLineWidth: CGFloat = 6
    
    @State private var showingActionsForIndex: Int? = nil
    @State private var showImageSourceSheet = false
    
    private let columns = [
        GridItem(.adaptive(minimum: Self.itemSize), spacing: Self.itemSpacing)
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, alignment: .leading, spacing: Self.itemSpacing) {
            ForEach(images.indices, id: \.self) { index in
                Image(uiImage: images[index])
                    .resizable()
                    .scaledToFill()
                    .frame(width: Self.itemSize, height: Self.itemSize)
                    .clipShape(RoundedRectangle(cornerRadius: Self.itemCornerRadius))
                    .overlay {
                        if showingActionsForIndex == index {
                            RoundedRectangle(cornerRadius: Self.itemCornerRadius)
                                .stroke(Color.accentColor, lineWidth: Self.selectionLineWidth)
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
    
    private var imageActionMenu: some View {
        VStack(alignment: .leading, spacing: 32) {
            Button {
                if let index = showingActionsForIndex {
                    onTapImage(index)
                    showingActionsForIndex = nil
                }
            } label: {
                HStack {
                    Text("Show")
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
                    Text("Delete")
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

let mockImage1 = MockImageStorage.generateMockImage(text: "TEST IMAGE 1", size: CGSize(width: 100, height: 100), backgroundColor: UIColor.yellow, textColor: UIColor.gray)
let mockImage2 = MockImageStorage.generateMockImage(text: "TEST IMAGE 2", size: CGSize(width: 100, height: 100), backgroundColor: UIColor.green, textColor: UIColor.black)
let mockImage3 = MockImageStorage.generateMockImage(text: "TEST IMAGE 3", size: CGSize(width: 100, height: 100), backgroundColor: UIColor.red, textColor: UIColor.white)

let mockImages = [mockImage1, mockImage2, mockImage3, mockImage1, mockImage2, mockImage3, mockImage1, mockImage2, mockImage3]

#Preview("Light") {
    ShoppingItemImageGridView(images: mockImages, onUserInteraction: {},
                              onAddImage: {_ in}, onTapImage: {_ in}, onDeleteImage: {_ in})
        .padding()
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    ShoppingItemImageGridView(images: mockImages, onUserInteraction: {},
                              onAddImage: {_ in}, onTapImage: {_ in}, onDeleteImage: {_ in})
        .padding()
        .preferredColorScheme(.dark)
}
