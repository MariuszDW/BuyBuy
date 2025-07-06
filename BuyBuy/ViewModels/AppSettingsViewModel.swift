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
    @Published var isCloudSyncEnabled: Bool
    @Published var progressIndicator: Bool
    @Published var iCloudErrorMessage: String?
    
    init(dataManager: DataManagerProtocol, preferences: AppPreferencesProtocol, coordinator: any AppCoordinatorProtocol) {
        self.dataManager = dataManager
        self.coordinator = coordinator
        self.preferences = preferences
        
        self.isMetricUnitsEnabled = preferences.isMetricUnitsEnabled
        self.isImperialUnitsEnabled = preferences.isImperialUnitsEnabled
        self.progressIndicator = false
        self.isCloudSyncEnabled = preferences.isCloudSyncEnabled
    }
    
    func setMetricUnitsEnabled(_ enabled: Bool) {
        isMetricUnitsEnabled = enabled
        preferences.isMetricUnitsEnabled = enabled
    }
    
    func setImperialUnitsEnabled(_ enabled: Bool) {
        isImperialUnitsEnabled = enabled
        preferences.isImperialUnitsEnabled = enabled
    }
    
    func setCloudStorage(enabled: Bool) {
        guard enabled != preferences.isCloudSyncEnabled else { return }
        progressIndicator = true
        
        Task {
            if enabled {
                let result = await ICloudStatusChecker.checkStatus()
                guard result.isFullyAvailable else {
                    isCloudSyncEnabled = false
                    progressIndicator = false
                    await MainActor.run {
                        iCloudErrorMessage = result.errorsMessage
                    }
                    return
                }
            }
            
            await coordinator.setupDataManager(useCloud: enabled)
            isCloudSyncEnabled = preferences.isCloudSyncEnabled
            progressIndicator = false
        }
    }
    
    func openTipJar() {
        coordinator.openTipJar(onDismiss: {_ in })
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
