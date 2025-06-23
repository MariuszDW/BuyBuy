//
//  AppDependencies.swift
//  BuyBuy
//
//  Created by MDW on 15/05/2025.
//

import SwiftUI

final class AppDependencies: ObservableObject {
    let preferences: AppPreferences
    let imageStorage: ImageStorage
    let fileStorage: FileStorage
    let coreDataStack: CoreDataStack
    let repository: DataRepository
    let dataManager: DataManager
    
    @MainActor
    init() {
        self.preferences = AppPreferences()
        self.imageStorage = ImageStorage( useCloudSync: preferences.isCloudSyncEnabled)
        self.fileStorage = FileStorage()
        self.coreDataStack = CoreDataStack(useCloudSync: preferences.isCloudSyncEnabled)
        self.repository = DataRepository(coreDataStack: coreDataStack)
        self.dataManager = DataManager(repository: repository, imageStorage: imageStorage, fileStorage: fileStorage)
    }
}
