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
        ShoppingList(name: "First list", items: [
            ShoppingItem(name: "one", status: .pending),
            ShoppingItem(name: "two", status: .purchased),
            ShoppingItem(name: "three", status: .inactive),
            ShoppingItem(name: "found", status: .pending)
        ], order: 0, icon: .clothes, color: .red),
        
        ShoppingList(name: "Second list", items: [
            ShoppingItem(name: "one", status: .purchased),
            ShoppingItem(name: "two", status: .purchased),
            ShoppingItem(name: "three", status: .pending),
            ShoppingItem(name: "found", status: .purchased),
            ShoppingItem(name: "found", status: .purchased)
        ], order: 1, icon: .fish, color: .green),
        
        ShoppingList(name: "Third list", items: [
        ], order: 2, icon: .car, color: .yellow)
    ])

    init(designSystem: DesignSystem = DesignSystem()) {
        self.designSystem = designSystem
    }
}
