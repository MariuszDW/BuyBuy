//
//  BuyBuyApp.swift
//  BuyBuy
//
//  Created by MDW on 14/05/2025.
//

import SwiftUI
import CloudKit
import os

@main
struct BuyBuyApp: App {
    let preferences: AppPreferences
    @StateObject var coordinator: AppCoordinator
    var memoryWarningObserver: MemoryWarningObserver

    @UIApplicationDelegateAdaptor var appDelegate: AppDelegate

    init() {
        preferences = AppPreferences()
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

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    func windowScene(_ windowScene: UIWindowScene,
                     userDidAcceptCloudKitShareWith cloudKitShareMetadata: CKShare.Metadata) {
        os_log("Enqueued pending share from warn start: %{public}@", log: .main, type: .default, "\(cloudKitShareMetadata)")
        AppCoordinator.enqueuePendingShare(cloudKitShareMetadata)
    }
}

class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        if let cloudKitMetadata = options.cloudKitShareMetadata {
            os_log("Enqueued pending share from cold start: %{public}@", log: .main, type: .default, "\(cloudKitMetadata)")
            AppCoordinator.enqueuePendingShare(cloudKitMetadata)
        }

        let config = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        config.delegateClass = SceneDelegate.self
        return config
    }
}
