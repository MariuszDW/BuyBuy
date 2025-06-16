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
    private var preferences: AppPreferencesProtocol
    
    @Published var isMetricUnitsEnabled: Bool
    @Published var isImperialUnitsEnabled: Bool
    
    init(dataManager: DataManagerProtocol, preferences: AppPreferencesProtocol, coordinator: any AppCoordinatorProtocol) {
        self.dataManager = dataManager
        self.coordinator = coordinator
        self.preferences = preferences
        
        self.isMetricUnitsEnabled = preferences.isMetricUnitsEnabled
        self.isImperialUnitsEnabled = preferences.isImperialUnitsEnabled
    }
    
    func setMetricUnitsEnabled(_ enabled: Bool) {
        isMetricUnitsEnabled = enabled
        preferences.isMetricUnitsEnabled = enabled
    }
    
    func setImperialUnitsEnabled(_ enabled: Bool) {
        isImperialUnitsEnabled = enabled
        preferences.isImperialUnitsEnabled = enabled
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
