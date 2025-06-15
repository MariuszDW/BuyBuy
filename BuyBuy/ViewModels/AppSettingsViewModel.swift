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
    var coordinator: any AppCoordinatorProtocol
    
    init(dataManager: DataManagerProtocol, coordinator: any AppCoordinatorProtocol) {
        self.dataManager = dataManager
        self.coordinator = coordinator
    }
    
#if DEBUG
    func copyMockToData() async {
        MockDataRepository.allLists.forEach { list in
            Task {
                try? await dataManager.addOrUpdateList(list)
            }
        }
        MockDataRepository.allCards.forEach { card in
            Task {
                try? await dataManager.addOrUpdateLoyaltyCard(card)
            }
        }
        MockDataRepository.deletedItems.forEach { item in
            Task {
                try? await dataManager.addOrUpdateItem(item)
            }
        }
    }
#endif
}
