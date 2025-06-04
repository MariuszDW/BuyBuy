//
//  FullscreenImageView.swift
//  BuyBuy
//
//  Created by MDW on 01/06/2025.
//

import SwiftUI

struct FullscreenImageView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject var viewModel: FullscreenImageViewModel

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Group {
                if let image = viewModel.image {
                    ZoomableImageView(image: image, onDismiss: {
                        dismiss()
                    })
                } else if viewModel.showProgressIndicator {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .bb.text.primary))
                        .controlSize(.large)
                } else {
                    emptyView
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            Button(action: { dismiss() }) {
                Image(systemName: "xmark.circle")
                    .font(.system(size: 30))
                    .foregroundColor(.white)
                    .shadow(color: .black, radius: 3)
                    .padding()
            }
        }
        .background(Color.background.ignoresSafeArea())
    }
    
    private var emptyView: some View {
        GeometryReader { geometry in
            let baseSize = min(geometry.size.width, geometry.size.height)
            
            VStack(spacing: 50) {
                AnimatedIconView(
                    image: Image(systemName: "questionmark.circle"),
                    color: .bb.text.quaternary,
                    size: baseSize * 0.5,
                    response: 0.8,
                    dampingFraction: 0.3
                )
                
                Text("No image found.")
                    .font(.boldDynamic(style: .title2))
                    .foregroundColor(.bb.text.tertiary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .position(x: geometry.size.width * 0.5, y: geometry.size.height * 0.5)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 40)
    }
}

// MARK: - Preview

#Preview("Light") {
    let dataManager = DataManager(repository: MockDataRepository(lists: []),
                                  imageStorage: MockImageStorage())
    let viewModel = FullscreenImageViewModel(imageID: UUID().uuidString,
                                             imageType: .itemImage,
                                             dataManager: dataManager)
    FullscreenImageView(viewModel: viewModel)
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    let dataManager = DataManager(repository: MockDataRepository(lists: []),
                                  imageStorage: MockImageStorage())
    let viewModel = FullscreenImageViewModel(imageID: UUID().uuidString,
                                             imageType: .itemImage,
                                             dataManager: dataManager)
    FullscreenImageView(viewModel: viewModel)
        .preferredColorScheme(.dark)
}

#Preview("Light/empty") {
    let dataManager = DataManager(repository: MockDataRepository(lists: []),
                                  imageStorage: MockImageStorage())
    let viewModel = FullscreenImageViewModel(imageID: nil,
                                             imageType: .itemImage,
                                             dataManager: dataManager)
    FullscreenImageView(viewModel: viewModel)
        .preferredColorScheme(.light)
}

#Preview("Dark/empty") {
    let dataManager = DataManager(repository: MockDataRepository(lists: []),
                                  imageStorage: MockImageStorage())
    let viewModel = FullscreenImageViewModel(imageID: nil,
                                             imageType: .itemImage,
                                             dataManager: dataManager)
    FullscreenImageView(viewModel: viewModel)
        .preferredColorScheme(.dark)
}
