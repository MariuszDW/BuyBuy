//
//  ShoppingItem.swift
//  BuyBuy
//
//  Created by MDW on 15/05/2025.
//

import Foundation

struct ShoppingItem: Identifiable, Hashable {
    let id: UUID
    var listID: UUID?
    var name: String
    var note: String
    var status: ShoppingItemStatus
    var order: Int
    var price: Double?
    var quantity: Double?
    var unit: ShoppingItemUnit?
    var deletedAt: Date?
    var imageIDs: [String] = []
    
    var quantityWithUnit: String? {
        guard let quantityString = quantity?.quantityFormat, !quantityString.isEmpty else {
            return nil
        }
        if let unitString = unit?.symbol, !unitString.isEmpty {
            return quantityString + " " + unitString
        } else {
            return quantityString
        }
    }
    
    var totalPrice: Double? {
        guard let price = price else {
            return nil
        }
        return price * (quantity ?? 1)
    }

    init(id: UUID = UUID(), order: Int, listID: UUID?, name: String, note: String = "", status: ShoppingItemStatus, price: Double? = nil, quantity: Double? = nil, unit: ShoppingItemUnit? = nil, deletedAt: Date? = nil, imageIDs: [String] = []) {
        self.id = id
        self.order = order
        self.listID = listID
        self.name = name
        self.note = note
        self.status = status
        self.price = price
        self.quantity = quantity
        self.unit = unit
        self.deletedAt = deletedAt
        self.imageIDs = imageIDs
    }
    
    var isInTrash: Bool {
        deletedAt != nil
    }
    
    mutating func prepareToSave() {
        name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        note = note.trimmingCharacters(in: .whitespacesAndNewlines)
        price = price?.priceRound
        quantity = quantity?.quantityRound
    }
}
