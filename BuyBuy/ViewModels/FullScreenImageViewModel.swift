//
//  FullScreenImageViewModel.swift
//  BuyBuy
//
//  Created by MDW on 01/06/2025.
//

import SwiftUI

enum ImageLoadState {
    case loading
    case success(UIImage)
    case failure
}

@MainActor
final class FullScreenImageViewModel: ObservableObject {
    @Published var state: ImageLoadState = .loading
    @Published private(set) var currentIndex: Int = 0

    let imageIDs: [String]
    let imageType: ImageType
    private let dataManager: DataManagerProtocol
    let coordinator: any AppCoordinatorProtocol

    init(imageIDs: [String], startIndex: Int = 0, imageType: ImageType, dataManager: DataManagerProtocol, coordinator: any AppCoordinatorProtocol) {
        self.imageIDs = imageIDs
        self.imageType = imageType
        self.dataManager = dataManager
        self.coordinator = coordinator
        self.currentIndex = startIndex
        Task {
            await loadImage(at: currentIndex)
        }
    }

    var hasPrevious: Bool {
        currentIndex > 0
    }

    var hasNext: Bool {
        currentIndex < imageIDs.count - 1
    }

    func loadImage(at index: Int) async {
        guard imageIDs.indices.contains(index) else {
            state = .failure
            return
        }
        state = .loading
        do {
            if let image = try await dataManager.loadImage(baseFileName: imageIDs[index], type: imageType) {
                state = .success(image)
            }
            else {
                state = .failure
            }
        } catch {
            state = .failure
        }
    }
    
    func reloadCurrentImageIfNeeded() async {
        if case .success = state {
            return
        }
        await loadImage(at: currentIndex)
    }

    func showNextImage() {
        guard hasNext else { return }
        currentIndex += 1
        Task { await loadImage(at: currentIndex) }
    }

    func showPreviousImage() {
        guard hasPrevious else { return }
        currentIndex -= 1
        Task { await loadImage(at: currentIndex) }
    }
}
