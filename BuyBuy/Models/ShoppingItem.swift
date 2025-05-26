//
//  ShoppingItem.swift
//  BuyBuy
//
//  Created by MDW on 15/05/2025.
//

import Foundation

struct ShoppingItem: Identifiable, Hashable {
    let id: UUID
    let listID: UUID
    var name: String
    var note: String
    var status: ShoppingItemStatus
    var order: Int
    var price: Double?
    var quantity: Double?
    var unit: ShoppingItemUnit?

    init(id: UUID = UUID(), order: Int, listID: UUID, name: String, note: String = "", status: ShoppingItemStatus, price: Double? = nil, quantity: Double? = nil, unit: ShoppingItemUnit? = nil) {
        self.id = id
        self.order = order
        self.listID = listID
        self.name = name
        self.note = note
        self.status = status
        self.price = price
        self.quantity = quantity
    }
    
    mutating func prepareToSave() {
        name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        note = note.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
