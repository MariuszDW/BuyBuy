//
//  FullscreenImageViewModel.swift
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
final class FullscreenImageViewModel: ObservableObject {
    @Published var state: ImageLoadState = .loading

    let imageID: String?
    let imageType: ImageType
    private let dataManager: DataManagerProtocol

    init(imageID: String?, imageType: ImageType, dataManager: DataManagerProtocol) {
        self.imageID = imageID
        self.imageType = imageType
        self.dataManager = dataManager
        Task {
            await loadImage()
        }
    }

    func loadImage() async {
        guard let imageID = imageID else {
            state = .failure
            return
        }
        do {
            let image = try await dataManager.loadImage(baseFileName: imageID, type: imageType)
            state = .success(image)
        } catch {
            state = .failure
        }
    }
}
