//
//  BuyBuyApp.swift
//  BuyBuy
//
//  Created by MDW on 14/05/2025.
//

import SwiftUI

@main
struct BuyBuyApp: App {
    @StateObject var dependencies: AppDependencies
    @StateObject var coordinator: AppCoordinator
    
    init() {
        let appDependencies = AppDependencies()
        _dependencies = StateObject(wrappedValue: appDependencies)
        _coordinator = StateObject(wrappedValue: AppCoordinator(dependencies: appDependencies))
    }
    
    var body: some Scene {
        WindowGroup {
            AppRootView(coordinator: coordinator)
                .environmentObject(dependencies)
                .task {
                    await coordinator.performStartupTasks()
                }
        }
    }
}
