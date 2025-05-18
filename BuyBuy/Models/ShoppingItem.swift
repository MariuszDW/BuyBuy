//
//  ShoppingItem.swift
//  BuyBuy
//
//  Created by MDW on 15/05/2025.
//

import Foundation

struct ShoppingItem: Identifiable, Hashable {
    let id: UUID
    var name: String
    var note: String?
    var status: ShoppingItemStatus

    init(id: UUID = UUID(), name: String, note: String? = nil, status: ShoppingItemStatus) {
        self.id = id
        self.name = name
        self.note = note
        self.status = status
    }
}
