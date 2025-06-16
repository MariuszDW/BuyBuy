//
//  AppDependencies.swift
//  BuyBuy
//
//  Created by MDW on 15/05/2025.
//

import SwiftUI

@MainActor
final class AppDependencies: ObservableObject {
    private let coreDataStack: CoreDataStack
    private let repository: DataRepositoryProtocol
    private let imageStorage: ImageStorageProtocol
    private let fileStorage: FileStorageProtocol
    let dataManager: DataManager
    let preferences: AppPreferences

    init() {
        self.coreDataStack = CoreDataStack()
        self.repository = DataRepository(coreDataStack: coreDataStack)
        self.imageStorage = ImageStorage()
        self.fileStorage = FileStorage()
        self.dataManager = DataManager(repository: repository, imageStorage: imageStorage, fileStorage: fileStorage)
        self.preferences = AppPreferences()
    }
}
