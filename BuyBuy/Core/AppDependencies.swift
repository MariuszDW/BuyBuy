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
        ShoppingList(
            id: UUID(),
            name: "Supermarket",
            items: [
                ShoppingItem(id: UUID(), name: "Milk", status: .pending),
                ShoppingItem(id: UUID(), name: "Bread", status: .purchased),
                ShoppingItem(id: UUID(), name: "Eggs", status: .inactive)
            ],
            order: 0
        ),
        ShoppingList(
            id: UUID(),
            name: "Hardware Store",
            items: [
                ShoppingItem(id: UUID(), name: "Nails", status: .pending),
                ShoppingItem(id: UUID(), name: "Hammer", status: .purchased)
            ],
            order: 1
        ),
        ShoppingList(
            id: UUID(),
            name: "Empty",
            items: [],
            order: 2
        )
    ])

    init(designSystem: DesignSystem = DesignSystem()) {
        self.designSystem = designSystem
    }
}
