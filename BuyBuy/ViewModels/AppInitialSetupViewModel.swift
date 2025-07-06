//
//  AppInitialSetupViewModel.swift
//  BuyBuy
//
//  Created by MDW on 05/07/2025.
//

import Foundation

@MainActor
class AppInitialSetupViewModel: ObservableObject {
    var coordinator: any AppCoordinatorProtocol
    private var preferences: any AppPreferencesProtocol
    
    @Published var isCloudSelected: Bool
    @Published var showProgressIndicator: Bool = false
    @Published var iCloudErrorMessage: String?
    @Published var canDismiss: Bool = false
    
    init(preferences: any AppPreferencesProtocol, coordinator: any AppCoordinatorProtocol) {
        self.preferences = preferences
        self.coordinator = coordinator
        self.isCloudSelected = preferences.isCloudSyncEnabled
    }
    
    func verifyInitSetup() {
        if isCloudSelected != preferences.isCloudSyncEnabled {
            showProgressIndicator = true
            
            Task {
                if isCloudSelected {
                    let result = await ICloudStatusChecker.checkStatus()
                    guard result.isFullyAvailable else {
                        showProgressIndicator = false
                        await MainActor.run {
                            iCloudErrorMessage = result.errorsMessage
                        }
                        return
                    }
                }
                
                preferences.installationDate = Date()
                showProgressIndicator = false
                canDismiss = true
                await coordinator.setupDataManager(useCloud: isCloudSelected)
            }
        } else {
            preferences.installationDate = Date()
            canDismiss = true
        }
    }
}
