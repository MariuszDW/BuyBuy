//
//  SettingsViewModel.swift
//  BuyBuy
//
//  Created by MDW on 16/05/2025.
//

import Foundation

class SettingsViewModel: ObservableObject {
    private var coordinator: any AppCoordinatorProtocol

    init(coordinator: any AppCoordinatorProtocol) {
        self.coordinator = coordinator
    }

    func close() {
        coordinator.back()
    }
}
