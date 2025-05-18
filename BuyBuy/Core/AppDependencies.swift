//
//  AppDependencies.swift
//  BuyBuy
//
//  Created by MDW on 15/05/2025.
//

import SwiftUI

final class AppDependencies: ObservableObject {
    @Published var designSystem: DesignSystem
    
    // TODO: temporary data
    let shoppingListStore = InMemoryShoppingListStore(initialLists: [
        ShoppingList(id: UUID(), name: "First list", items: [
            ShoppingItem(id: UUID(), name: "one", status: .pending),
            ShoppingItem(id: UUID(), name: "two", status: .purchased),
            ShoppingItem(id: UUID(), name: "three", status: .inactive),
            ShoppingItem(id: UUID(), name: "found", status: .pending)
        ], order: 0, icon: .clothes, color: .red),
        
        ShoppingList(id: UUID(), name: "Second list", items: [
            ShoppingItem(id: UUID(), name: "one", status: .purchased),
            ShoppingItem(id: UUID(), name: "two", status: .purchased),
            ShoppingItem(id: UUID(), name: "three", status: .pending),
            ShoppingItem(id: UUID(), name: "found", status: .purchased),
            ShoppingItem(id: UUID(), name: "found", status: .purchased)
        ], order: 1, icon: .fish, color: .green),
        
        ShoppingList(id: UUID(), name: "Third list", items: [
        ], order: 2, icon: .car, color: .yellow)
    ])

    init(designSystem: DesignSystem = DesignSystem()) {
        self.designSystem = designSystem
    }
}
