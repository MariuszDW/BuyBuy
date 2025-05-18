//
//  ShoppingItemStatus.swift
//  BuyBuy
//
//  Created by MDW on 15/05/2025.
//

enum ShoppingItemStatus: String, CaseIterable, Hashable {
    case pending    // Item is yet to be purchased (active).
    case purchased  // Item has been bought (done).
    case inactive   // Item is currently not relevant or temporarily inactive.
}
