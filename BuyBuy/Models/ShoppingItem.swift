//
//  ShoppingItem.swift
//  BuyBuy
//
//  Created by MDW on 15/05/2025.
//

import Foundation

struct ShoppingItem: Identifiable, Hashable {
    let id: UUID
    let name: String
    let status: ShoppingItemStatus
}
