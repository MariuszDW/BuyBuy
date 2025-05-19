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
        ShoppingList(name: "Grocery Store", items: [
            ShoppingItem(name: "Milk", status: .pending),
            ShoppingItem(name: "Bread", status: .purchased),
            ShoppingItem(name: "Eggs", status: .inactive),
            ShoppingItem(name: "Apples", status: .pending),
            ShoppingItem(name: "Chicken", status: .purchased),
            ShoppingItem(name: "Butter", status: .purchased),
            ShoppingItem(name: "Yogurt", status: .inactive)
        ], order: 0, icon: .cart, color: .orange),

        ShoppingList(name: "Hardware Store", items: [
            ShoppingItem(name: "Screws", status: .purchased),
            ShoppingItem(name: "Hammer", status: .pending),
            ShoppingItem(name: "Paint", status: .inactive),
            ShoppingItem(name: "Wrench", status: .purchased),
            ShoppingItem(name: "Drill", status: .pending),
            ShoppingItem(name: "Tape Measure", status: .purchased),
            ShoppingItem(name: "Ladder", status: .inactive),
            ShoppingItem(name: "Sandpaper", status: .pending)
        ], order: 1, icon: .house, color: .brown),

        ShoppingList(name: "Sports Equipment", items: [
            ShoppingItem(name: "Football", status: .pending),
            ShoppingItem(name: "Tennis Racket", status: .purchased),
            ShoppingItem(name: "Running Shoes", status: .purchased),
            ShoppingItem(name: "Yoga Mat", status: .inactive),
            ShoppingItem(name: "Water Bottle", status: .pending),
            ShoppingItem(name: "Sweatband", status: .inactive),
            ShoppingItem(name: "Gym Bag", status: .pending),
            ShoppingItem(name: "Basketball", status: .purchased),
            ShoppingItem(name: "Swim Goggles", status: .purchased)
        ], order: 2, icon: .run, color: .blue),

        ShoppingList(name: "Pet Supplies", items: [
            ShoppingItem(name: "Cat Food", status: .purchased),
            ShoppingItem(name: "Dog Leash", status: .inactive),
            ShoppingItem(name: "Bird Seed", status: .pending),
            ShoppingItem(name: "Pet Shampoo", status: .purchased),
            ShoppingItem(name: "Dog Treats", status: .pending),
            ShoppingItem(name: "Cat Litter", status: .inactive),
            ShoppingItem(name: "Fish Tank Filter", status: .purchased)
        ], order: 3, icon: .cat, color: .pink)
    ]
)

    init(designSystem: DesignSystem = DesignSystem()) {
        self.designSystem = designSystem
    }
}
