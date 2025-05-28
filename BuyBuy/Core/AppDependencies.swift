//
//  AppDependencies.swift
//  BuyBuy
//
//  Created by MDW on 15/05/2025.
//

import SwiftUI

final class AppDependencies: ObservableObject {
    private let coreDataStack = CoreDataStack()
    lazy var repository: ShoppingListsRepositoryProtocol = {
        ShoppingListsRepository(coreDataStack: coreDataStack)
    }()
    
    lazy var imageStorage: ImageStorageServiceProtocol = {
        ImageStorageService()
    }()
}
