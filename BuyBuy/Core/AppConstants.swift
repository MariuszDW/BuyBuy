//
//  AppConstants.swift
//  BuyBuy
//
//  Created by MDW on 14/06/2025.
//

import Foundation

struct AppConstants {
    static let autoDeleteAfterDays: Int = 30 // TODO: It should be set in the application settings.
    static let cleanupIntervalMinutes: Double = 60 * 12
    static let remoteChangeTimeoutSeconds: TimeInterval = 120
    
    static let encoreContactEMail: String = "encore_contact@icloud.com"
    
    static let blueSkyAddress: String = "https://encore-games.bsky.social"
    static let blueSkyName: String = "Bluesky"
    
    static var bundleID: String? { Bundle.main.bundleIdentifier }
#if BUYBUY_DEV
    static let appGroupID = "group.com.encore.BuyBuyDev"
    static let iCloudContainerID = "iCloud.com.encore.BuyBuyDev"
#else
    static let appGroupID = "group.com.encore.BuyBuy"
    static let iCloudContainerID = "iCloud.com.encore.BuyBuy"
#endif
    
    static let coreDataModelName = "Model"
    static let localStoreFileName = "LocalStore.sqlite"
    static let privateCloudStoreFileName = "CloudStore.sqlite"
    static let sharedCloudStoreFileName = "SharedStore.sqlite"
    
#if BUYBUY_DEV
    static let tipIDs = ["small_tip_dev", "medium_tip_dev", "large_tip_dev"]
#else
    static let tipIDs = ["small_tip", "medium_tip", "large_tip"]
#endif
    
    /// How often to remind users who never tipped.
    static let tipReminderIntervalNeverTippedDays: Int = 30
    
    /// How often to remind users who have tipped at least once
    static let tipReminderIntervalTippedDays: Int = 180
}
