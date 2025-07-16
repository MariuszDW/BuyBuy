//
//  AppInitialSetupViewModel.swift
//  BuyBuy
//
//  Created by MDW on 05/07/2025.
//

import Foundation

@MainActor
class AppInitialSetupViewModel: ObservableObject {
    private weak var coordinator: (any AppCoordinatorProtocol)?
    private var preferences: any AppPreferencesProtocol
    
    @Published var isCloudSelected: Bool
    @Published var metricSystem: Bool = true
    @Published var imperialSystem: Bool = true
    @Published var showProgressIndicator: Bool = false
    @Published var iCloudErrorMessage: String?
    @Published var canDismiss: Bool = false
    
    init(preferences: any AppPreferencesProtocol, coordinator: any AppCoordinatorProtocol) {
        self.preferences = preferences
        self.coordinator = coordinator
        self.isCloudSelected = preferences.isCloudSyncEnabled
        self.metricSystem = Locale.current.measurementSystem == .metric
        self.imperialSystem = !self.metricSystem
    }
    
    func verifyInitSetup() {
        preferences.isMetricUnitsEnabled = metricSystem
        preferences.isImperialUnitsEnabled = imperialSystem
        
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
                let strongSelf = self
                await coordinator?.setupDataManager(useCloud: isCloudSelected) {
                    strongSelf.showProgressIndicator = false
                    strongSelf.canDismiss = true
                }
            }
        } else {
            preferences.installationDate = Date()
            canDismiss = true
        }
    }
}
