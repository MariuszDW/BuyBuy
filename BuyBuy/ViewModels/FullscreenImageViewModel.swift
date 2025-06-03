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
    let imageType: ImageType
    private let dataManager: DataManagerProtocol

    init(imageID: String, imageType: ImageType, dataManager: DataManagerProtocol) {
        self.imageID = imageID
        self.imageType = imageType
        self.dataManager = dataManager
        Task {
            await loadImage()
        }
    }
    
    func loadImage() async {
        image = try? await dataManager.loadImage(baseFileName: imageID, type: imageType)
    }
}
