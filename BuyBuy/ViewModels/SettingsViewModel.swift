//
//  SettingsViewModel.swift
//  BuyBuy
//
//  Created by MDW on 16/05/2025.
//

import Foundation

final class SettingsViewModel: ObservableObject {
    private weak var coordinator: AppCoordinatorProtocol?

    init(coordinator: AppCoordinatorProtocol?) {
        self.coordinator = coordinator
    }

    func close() {
        coordinator?.back()
    }
}
