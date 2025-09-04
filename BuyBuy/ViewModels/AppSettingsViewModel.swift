//
//  AppSettingsViewModel.swift
//  BuyBuy
//
//  Created by MDW on 16/05/2025.
//

import Foundation
import SwiftUI

@MainActor
class AppSettingsViewModel: ObservableObject {
    private let dataManager: DataManagerProtocol
    private weak var coordinator: (any AppCoordinatorProtocol)?
    private var hapticEngine: any HapticEngineProtocol
    private var preferences: AppPreferencesProtocol
    
    @Published var isMetricUnitsEnabled: Bool
    @Published var isImperialUnitsEnabled: Bool
    @Published var isCloudSyncEnabled: Bool
    @Published var isHapticsEnabled: Bool
    @Published var progressIndicator: Bool
    @Published var iCloudErrorMessage: String?
    
    init(dataManager: DataManagerProtocol, hapticEngine: HapticEngineProtocol, preferences: AppPreferencesProtocol, coordinator: any AppCoordinatorProtocol) {
        self.dataManager = dataManager
        self.hapticEngine = hapticEngine
        self.coordinator = coordinator
        self.preferences = preferences
        
        self.isMetricUnitsEnabled = preferences.isMetricUnitsEnabled
        self.isImperialUnitsEnabled = preferences.isImperialUnitsEnabled
        self.progressIndicator = false
        self.isCloudSyncEnabled = preferences.isCloudSyncEnabled
        self.isHapticsEnabled = preferences.isHapticsEnabled
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
            
            let strongSelf = self
            await coordinator?.setupDataManager(useCloud: enabled) {
                strongSelf.isCloudSyncEnabled = strongSelf.preferences.isCloudSyncEnabled
                strongSelf.progressIndicator = false
            }
        }
    }
    
    func setHapticsEnabled(_ enabled: Bool) {
        isHapticsEnabled = enabled
        preferences.isHapticsEnabled = enabled
        hapticEngine.isEnabled = enabled
    }
    
    func openTipJar() {
        coordinator?.openTipJar(onDismiss: {_ in })
    }
    
#if BUYBUY_DEV
    func copyMockToData() async {
        // TODO: Modify copying mock to database...
        
        for list in MockDataRepository.allLists {
            try? await dataManager.addOrUpdateShoppingList(list)
        }

        for item in MockDataRepository.deletedItems {
            try? await dataManager.addOrUpdateShoppingItem(item)
        }

        if let itemImageIDs = try? await dataManager.fetchShoppingItemImageIDs() {
            for imageID in itemImageIDs {
                if let image = UIImage(named: imageID) {
                    try? await dataManager.saveImageToTemporaryDir(image, baseFileName: imageID)
                }
            }
        }
        
        for item in MockDataRepository.deletedItems {
            try? await dataManager.addOrUpdateShoppingItem(item)
        }
        
        for list in MockDataRepository.allLists {
            try? await dataManager.addOrUpdateShoppingList(list)
        }
        
        for card in MockDataRepository.allCards {
            try? await dataManager.addOrUpdateLoyaltyCard(card)
        }

        if let cardImageIDs = try? await dataManager.fetchLoyaltyCardImageIDs() {
            for imageID in cardImageIDs {
                if let image = UIImage(named: imageID) {
                    try? await dataManager.saveImageToTemporaryDir(image, baseFileName: imageID)
                }
            }
        }
        
        for card in MockDataRepository.allCards {
            try? await dataManager.addOrUpdateLoyaltyCard(card)
        }

        await dataManager.cleanImageCache()
    }
#endif
}
