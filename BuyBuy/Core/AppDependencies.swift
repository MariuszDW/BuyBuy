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
            id: UUID(uuidString: "11111111-1111-1111-1111-111111111111")!,
            name: "Supermarket",
            items: [
                ShoppingItem(id: UUID(), name: "Milk", status: .active),
                ShoppingItem(id: UUID(), name: "Bread", status: .done),
                ShoppingItem(id: UUID(), name: "Eggs", status: .inactive)
            ]
        ),
        ShoppingList(
            id: UUID(uuidString: "22222222-2222-2222-2222-222222222222")!,
            name: "Hardware Store",
            items: [
                ShoppingItem(id: UUID(), name: "Nails", status: .active),
                ShoppingItem(id: UUID(), name: "Hammer", status: .done)
            ]
        )
    ])

    init(designSystem: DesignSystem = DesignSystem()) {
        self.designSystem = designSystem
    }
}
