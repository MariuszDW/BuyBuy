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
    let dataManager: DataManager

    init() {
        self.coreDataStack = CoreDataStack()
        self.repository = DataRepository(coreDataStack: coreDataStack)
        self.imageStorage = ImageStorage()
        self.dataManager = DataManager(repository: repository, imageStorage: imageStorage)
    }
}
