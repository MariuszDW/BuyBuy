//
//  FullScreenImageView.swift
//  BuyBuy
//
//  Created by MDW on 01/06/2025.
//

import SwiftUI

enum SlideDirection {
    case left, right
}

struct FullScreenImageView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject var viewModel: FullScreenImageViewModel
    @State private var isZoomedOut = true
    @State private var dragOffset: CGFloat = 0
    
    init(viewModel: FullScreenImageViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topTrailing) {
                content(in: geometry.size.width)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black)
                
                closeButton
                    .padding(.top, geometry.safeAreaInsets.top + 4)
                    .padding(.trailing, geometry.safeAreaInsets.trailing + 4)
            }
            .gesture(dragGesture(width: geometry.size.width))
            .ignoresSafeArea()
            .background(Color.black.ignoresSafeArea())
        }
        .onReceive(viewModel.coordinator.eventPublisher) { event in
            if case .loyaltyCardImageChanged = event, viewModel.imageType == .cardImage {
                Task { await viewModel.reloadCurrentImageIfNeeded() }
            } else if case .shoppingItemImageChanged = event, viewModel.imageType == .itemImage {
                Task { await viewModel.reloadCurrentImageIfNeeded() }
            }
        }
    }

    @ViewBuilder
    private func content(in width: CGFloat) -> some View {
        switch viewModel.state {
        case .loading:
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .controlSize(.large)

        case .success(let image):
            ZoomableImageView(
                image: image,
                isZoomedOut: $isZoomedOut
            )
            .offset(x: dragOffset)
            .animation(.easeOut(duration: 0.25), value: dragOffset)

        case .failure:
            emptyView
        }
    }

    private var closeButton: some View {
        Button(action: { dismiss() }) {
            Image(systemName: "xmark.circle")
                .font(.system(size: 30))
                .foregroundColor(.white)
                .shadow(color: .black, radius: 3)
        }
    }

    private var emptyView: some View {
        GeometryReader { geometry in
            let baseSize = min(geometry.size.width, geometry.size.height)

            VStack(spacing: 50) {
                Image(systemName: "questionmark.circle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: baseSize * 0.5, height: baseSize * 0.5)
                    .foregroundColor(.gray.opacity(0.5))

                Text("no_image_found")
                    .font(.boldDynamic(style: .title2))
                    .foregroundColor(.gray.opacity(0.6))
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 40)
    }

    private func dragGesture(width: CGFloat) -> some Gesture {
        DragGesture()
            .onChanged { value in
                guard isZoomedOut else { return }

                let translation = value.translation.width
                
                if translation < 0 && !viewModel.hasNext {
                    dragOffset = 0
                    return
                }
                
                if translation > 0 && !viewModel.hasPrevious {
                    dragOffset = 0
                    return
                }

                dragOffset = translation
            }
            .onEnded { value in
                guard isZoomedOut else { return }

                let horizontal = value.translation.width
                let vertical = value.translation.height

                // Swipe down - close the preview
                if vertical > 100 && abs(vertical) > abs(horizontal) {
                    dismiss()
                    return
                }

                // Swipe left - next image
                if horizontal < -width * 0.4, viewModel.hasNext {
                    withAnimation {
                        dragOffset = -width
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        viewModel.showNextImage()
                        dragOffset = 0
                    }
                    return
                }

                // Swipe right - previous image
                if horizontal > width * 0.4, viewModel.hasPrevious {
                    withAnimation {
                        dragOffset = width
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        viewModel.showPreviousImage()
                        dragOffset = 0
                    }
                    return
                }

                withAnimation {
                    dragOffset = 0
                }
            }
    }
}

// MARK: - Preview

#Preview("Light") {
    let dataManager = DataManager(useCloud: false,
                                  coreDataStack: MockCoreDataStack(),
                                  imageStorage: MockImageStorage(),
                                  fileStorage: MockFileStorage(),
                                  repository: MockDataRepository(lists: []))
    let preferences = MockAppPreferences()
    let coordinator = AppCoordinator(preferences: preferences)
    let viewModel = FullScreenImageViewModel(imageIDs: [UUID().uuidString],
                                             imageType: .itemImage,
                                             dataManager: dataManager,
                                             coordinator: coordinator)
    FullScreenImageView(viewModel: viewModel)
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    let dataManager = DataManager(useCloud: false,
                                  coreDataStack: MockCoreDataStack(),
                                  imageStorage: MockImageStorage(),
                                  fileStorage: MockFileStorage(),
                                  repository: MockDataRepository(lists: []))
    let preferences = MockAppPreferences()
    let coordinator = AppCoordinator(preferences: preferences)
    let viewModel = FullScreenImageViewModel(imageIDs: [UUID().uuidString],
                                             imageType: .itemImage,
                                             dataManager: dataManager,
                                             coordinator: coordinator)
    FullScreenImageView(viewModel: viewModel)
        .preferredColorScheme(.dark)
}

#Preview("Light/empty") {
    let dataManager = DataManager(useCloud: false,
                                  coreDataStack: MockCoreDataStack(),
                                  imageStorage: MockImageStorage(),
                                  fileStorage: MockFileStorage(),
                                  repository: MockDataRepository(lists: []))
    let preferences = MockAppPreferences()
    let coordinator = AppCoordinator(preferences: preferences)
    let viewModel = FullScreenImageViewModel(imageIDs: [],
                                             imageType: .itemImage,
                                             dataManager: dataManager,
                                             coordinator: coordinator)
    FullScreenImageView(viewModel: viewModel)
        .preferredColorScheme(.light)
}

#Preview("Dark/empty") {
    let dataManager = DataManager(useCloud: false,
                                  coreDataStack: MockCoreDataStack(),
                                  imageStorage: MockImageStorage(),
                                  fileStorage: MockFileStorage(),
                                  repository: MockDataRepository(lists: []))
    let preferences = MockAppPreferences()
    let coordinator = AppCoordinator(preferences: preferences)
    let viewModel = FullScreenImageViewModel(imageIDs: [],
                                             imageType: .itemImage,
                                             dataManager: dataManager,
                                             coordinator: coordinator)
    FullScreenImageView(viewModel: viewModel)
        .preferredColorScheme(.dark)
}
