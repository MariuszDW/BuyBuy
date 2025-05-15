//
//  ShoppingList.swift
//  BuyBuy
//
//  Created by MDW on 15/05/2025.
//

import Foundation

struct ShoppingList: Identifiable, Hashable {
    let id: UUID
    let name: String
    let items: [ShoppingItem]
}
