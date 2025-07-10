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
    
#if DEBUG
    func copyMockToData() async {
        MockDataRepository.allLists.forEach { list in
            Task {
                try? await dataManager.addOrUpdateList(list)
            }
        }
        
        MockDataRepository.allCards.enumerated().forEach { index, card in
            Task {
                try? await dataManager.addOrUpdateLoyaltyCard(card)

                let assetImageName = MockDataRepository.allCardImageFileNames[index]

                if let image = UIImage(named: assetImageName),
                   let imageID = card.imageID {
                    try? await dataManager.saveImage(image, baseFileName: imageID, types: [.cardImage, .cardThumbnail])
                } else {
                    print("Failed to load image for card: \(card.name), assetName: \(assetImageName), imageID: \(card.imageID ?? "nil")")
                }
            }
        }
        
        MockDataRepository.deletedItems.forEach { item in
            Task {
                try? await dataManager.addOrUpdateItem(item)
            }
        }
        
        await dataManager.cleanImageCache()
    }
#endif
}
