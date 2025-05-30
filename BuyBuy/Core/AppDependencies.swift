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
    private let repository: ShoppingListsRepositoryProtocol
    private let imageStorage: ImageStorageServiceProtocol
    let dataManager: DataManager

    init() {
        self.coreDataStack = CoreDataStack()
        self.repository = ShoppingListsRepository(coreDataStack: coreDataStack)
        self.imageStorage = ImageStorageService()
        self.dataManager = DataManager(repository: repository, imageStorage: imageStorage)
    }
}
