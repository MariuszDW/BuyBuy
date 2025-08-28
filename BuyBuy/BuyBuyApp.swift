//
//  BuyBuyApp.swift
//  BuyBuy
//
//  Created by MDW on 14/05/2025.
//

import SwiftUI

@main
struct BuyBuyApp: App {
    let preferences: AppPreferences
    @StateObject var coordinator: AppCoordinator
    var memoryWarningObserver: MemoryWarningObserver

    init() {
        preferences = AppPreferences()
        
        AppUpdateManager(preferences: preferences).handleApplicationUpdate()
        
        let appCoordinator = AppCoordinator(preferences: preferences)
        _coordinator = StateObject(wrappedValue: appCoordinator)
        
        memoryWarningObserver = MemoryWarningObserver {
            appCoordinator.handleMemoryWarning()
        }
    }

    var body: some Scene {
        WindowGroup {
            AppRootView(coordinator: coordinator)
        }
    }
}
