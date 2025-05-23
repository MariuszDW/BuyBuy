//
//  AppSettingsViewModel.swift
//  BuyBuy
//
//  Created by MDW on 16/05/2025.
//

import Foundation

@MainActor
class AppSettingsViewModel: ObservableObject {
    private let repository: ShoppingListsRepositoryProtocol
    private var coordinator: any AppCoordinatorProtocol
    
    init(repository: ShoppingListsRepositoryProtocol, coordinator: any AppCoordinatorProtocol) {
        self.repository = repository
        self.coordinator = coordinator
    }
    
#if DEBUG
    func copyMockToRepository() async {
        MockShoppingListsRepository.allLists.forEach { list in
            Task {
                try? await repository.addOrUpdateList(list)
            }
        }
    }
#endif
}
