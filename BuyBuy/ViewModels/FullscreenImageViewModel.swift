//
//  FullscreenImageViewModel.swift
//  BuyBuy
//
//  Created by MDW on 01/06/2025.
//

import SwiftUI

@MainActor
final class FullscreenImageViewModel: ObservableObject {
    @Published var image: UIImage?
    let imageID: String
    private let dataManager: DataManagerProtocol

    init(imageID: String, dataManager: DataManagerProtocol) {
        self.imageID = imageID
        self.dataManager = dataManager
        Task {
            await loadImage()
        }
    }
    
    func loadImage() async {
        let loadedImage = try? await dataManager.loadImage(baseFileName: imageID)
        image = loadedImage
    }
}
