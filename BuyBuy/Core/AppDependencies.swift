//
//  AppDependencies.swift
//  BuyBuy
//
//  Created by MDW on 15/05/2025.
//

import SwiftUI

final class AppDependencies: ObservableObject {
    // TODO: temporary data
    let shoppingListsStore: InMemoryShoppingListStore = InMemoryShoppingListStore(initialLists: [
        MockShoppingListsRepository.list1,
        MockShoppingListsRepository.list2,
        MockShoppingListsRepository.list3,
        MockShoppingListsRepository.list4
    ])
}
