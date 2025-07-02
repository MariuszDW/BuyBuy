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
    static let appGroupID = "group.com.encore.BuyBuy"
    static let iCloudContainerID = "iCloud.com.encore.BuyBuy"
    
    static let coreDataModelName = "Model"
    static let localStoreFileName = "LocalStore.sqlite"
    static let cloudStoreFileName = "CloudStore.sqlite"
    
    static let tipIDs = ["small_tip", "medium_tip", "large_tip"]
}
