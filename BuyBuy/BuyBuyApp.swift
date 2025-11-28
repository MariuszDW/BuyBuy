//
//  BuyBuyApp.swift
//  BuyBuy
//
//  Created by MDW on 14/05/2025.
//

import SwiftUI
import CloudKit

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
        AppLogger.general.info("Enqueued pending share from warn start.")
        AppCoordinator.enqueuePendingShare(cloudKitShareMetadata)
    }
    
    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {

        // cold start shortcut
        if let shortcut = connectionOptions.shortcutItem {
            AppCoordinator.pendingShortcutItem = shortcut
        }
    }
    
    func windowScene(_ windowScene: UIWindowScene,
                     performActionFor shortcutItem: UIApplicationShortcutItem,
                     completionHandler: @escaping (Bool) -> Void) {

        // warm start shortcut
        AppCoordinator.pendingShortcutItem = shortcutItem
        Task { @MainActor in
            AppCoordinator.currentInstance?.consumePendingShortcutIfAny()
        }

        completionHandler(true)
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        let title = String(localized: "loyalty_cards")
        UIApplication.shared.shortcutItems = [
            UIApplicationShortcutItem(
                type: QuickActionType.openLoyaltyCards.rawValue,
                localizedTitle: title,
                localizedSubtitle: nil,
                icon: UIApplicationShortcutIcon(systemImageName: "creditcard")
            )
        ]
    }
}

class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        if let cloudKitMetadata = options.cloudKitShareMetadata {
            AppLogger.general.info("Enqueued pending share from cold start.")
            AppCoordinator.enqueuePendingShare(cloudKitMetadata)
        }

        let config = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        config.delegateClass = SceneDelegate.self
        return config
    }
}
