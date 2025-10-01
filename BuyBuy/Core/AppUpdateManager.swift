//
//  AppUpdateManager.swift
//  BuyBuy
//
//  Created by MDW on 10/08/2025.
//

import Foundation

@MainActor
final class AppUpdateManager {
    private var preferences: AppPreferencesProtocol
    
    init(preferences: AppPreferencesProtocol) {
        self.preferences = preferences
    }
    
    func handleApplicationUpdate() {
        let lastAppVersionString = preferences.lastAppVersion
        let currentAppVersionString = Bundle.main.appVersion()
        
        guard preferences.installationDate != nil else {
            preferences.lastAppVersion = currentAppVersionString
            return
        }
        
        let lastAppVersion = Version(lastAppVersionString)
        let currentAppVersion = Version(currentAppVersionString)
        
        guard lastAppVersion < currentAppVersion else {
            preferences.lastAppVersion = currentAppVersionString
            return
        }
        
        performUpdate(from: lastAppVersionString, to: currentAppVersionString)
        preferences.lastAppVersion = currentAppVersionString
    }
    
    private func performUpdate(from oldVersion: String, to newVersion: String) {
        AppLogger.general.info("Updating from \(oldVersion, privacy: .public) to \(newVersion, privacy: .public)")
        
        if Version(oldVersion) <= Version("1.0.0") {
            preferences.legacyCloudImages = true
            preferences.legacyDeviceImages = true
        }
        
        let localMigrator = DataModelMigrator(storeURL: CoreDataStack.storeURL(fileName: AppConstants.localStoreFileName))
        do {
            try localMigrator.migrateIfNeeded()
        } catch {
            AppLogger.general.info("Local data migration failed: \(error, privacy: .public)")
            // TODO: handle an error
        }
        
        let cloudMigrator = DataModelMigrator(storeURL: CoreDataStack.storeURL(fileName: AppConstants.privateCloudStoreFileName))
        do {
            try cloudMigrator.migrateIfNeeded()
        } catch {
            AppLogger.general.error("Cloud data migration failed: \(error, privacy: .public)")
            // TODO: handle an error
        }
    }
}
