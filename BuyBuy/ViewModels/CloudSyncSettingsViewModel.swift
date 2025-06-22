//
//  CloudSyncSettingsViewModel.swift
//  BuyBuy
//
//  Created by MDW on 22/06/2025.
//

import Foundation

@MainActor
final class CloudSyncSettingsViewModel: ObservableObject {
    private let dataManager: DataManagerProtocol
    private let preferences: AppPreferencesProtocol
    var coordinator: any AppCoordinatorProtocol
    
    init(dataManager: DataManagerProtocol, preferences: AppPreferencesProtocol, coordinator: any AppCoordinatorProtocol) {
        self.dataManager = dataManager
        self.preferences = preferences
        self.coordinator = coordinator
    }
    
    var isCloudSyncEnabled: Bool {
        preferences.isCloudSyncEnabled
    }
    
    func enableCloudSync() {
        print("TODO: enable cloud sync...")
    }
    
    func disableCloudSynd() {
        print("TODO: disable cloud sync...")
    }
}
