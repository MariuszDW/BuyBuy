//
//  FullscreenImageViewModel.swift
//  BuyBuy
//
//  Created by MDW on 01/06/2025.
//

import SwiftUI

final class FullscreenImageViewModel: ObservableObject {
    let image: UIImage
    
    init(image: UIImage) {
        self.image = image
    }
}
