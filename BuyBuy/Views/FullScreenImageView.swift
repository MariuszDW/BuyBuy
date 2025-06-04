//
//  FullScreenImageView.swift
//  BuyBuy
//
//  Created by MDW on 01/06/2025.
//

import SwiftUI

struct FullScreenImageView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject var viewModel: FullScreenImageViewModel
    @State private var canDismissByDrag = true

    var body: some View {
        ZStack(alignment: .topTrailing) {
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .gesture(
                    DragGesture()
                        .onEnded { value in
                            if canDismissByDrag && value.translation.height > 100 {
                                dismiss()
                            }
                        }
                )

            Button(action: { dismiss() }) {
                Image(systemName: "xmark.circle")
                    .font(.system(size: 30))
                    .foregroundColor(.white)
                    .shadow(color: .black, radius: 3)
                    .padding()
            }
        }
        .background(Color.bb.background.ignoresSafeArea())
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .loading:
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .bb.text.primary))
                .controlSize(.large)

        case .success(let image):
            ZoomableImageView(
                image: image,
                canDismissByDrag: $canDismissByDrag
            )

        case .failure:
            emptyView
        }
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
    let viewModel = FullScreenImageViewModel(imageID: UUID().uuidString,
                                             imageType: .itemImage,
                                             dataManager: dataManager)
    FullScreenImageView(viewModel: viewModel)
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    let dataManager = DataManager(repository: MockDataRepository(lists: []),
                                  imageStorage: MockImageStorage())
    let viewModel = FullScreenImageViewModel(imageID: UUID().uuidString,
                                             imageType: .itemImage,
                                             dataManager: dataManager)
    FullScreenImageView(viewModel: viewModel)
        .preferredColorScheme(.dark)
}

#Preview("Light/empty") {
    let dataManager = DataManager(repository: MockDataRepository(lists: []),
                                  imageStorage: MockImageStorage())
    let viewModel = FullScreenImageViewModel(imageID: nil,
                                             imageType: .itemImage,
                                             dataManager: dataManager)
    FullScreenImageView(viewModel: viewModel)
        .preferredColorScheme(.light)
}

#Preview("Dark/empty") {
    let dataManager = DataManager(repository: MockDataRepository(lists: []),
                                  imageStorage: MockImageStorage())
    let viewModel = FullScreenImageViewModel(imageID: nil,
                                             imageType: .itemImage,
                                             dataManager: dataManager)
    FullScreenImageView(viewModel: viewModel)
        .preferredColorScheme(.dark)
}
