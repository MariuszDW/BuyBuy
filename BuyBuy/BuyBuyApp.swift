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
    @StateObject var memoryWarningObserver: MemoryWarningObserver

    init() {
        let appDependencies = AppDependencies()
        let appCoordinator = AppCoordinator(dependencies: appDependencies)

        _dependencies = StateObject(wrappedValue: appDependencies)
        _coordinator = StateObject(wrappedValue: appCoordinator)
        _memoryWarningObserver = StateObject(wrappedValue:
            MemoryWarningObserver {
                appCoordinator.handleMemoryWarning()
            }
        )
    }

    var body: some Scene {
        WindowGroup {
            AppRootView(coordinator: coordinator)
                .environmentObject(dependencies)
        }
    }
}
