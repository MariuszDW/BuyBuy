//
//  AboutViewModel.swift
//  BuyBuy
//
//  Created by MDW on 12/06/2025.
//

import SwiftUI

@MainActor
final class AboutViewModel: ObservableObject {
    var coordinator: any AppCoordinatorProtocol
    
    init(coordinator: any AppCoordinatorProtocol) {
        self.coordinator = coordinator
    }
}
