//
//  AppSettingsViewModel.swift
//  BuyBuy
//
//  Created by MDW on 16/05/2025.
//

import Foundation

@MainActor
class AppSettingsViewModel: ObservableObject {
    private let dataManager: DataManagerProtocol
    private var coordinator: any AppCoordinatorProtocol
    
    init(dataManager: DataManagerProtocol, coordinator: any AppCoordinatorProtocol) {
        self.dataManager = dataManager
        self.coordinator = coordinator
    }
    
#if DEBUG
    func copyMockToData() async {
        MockShoppingListsRepository.allLists.forEach { list in
            Task {
                try? await dataManager.addOrUpdateList(list)
            }
        }
    }
#endif
}
