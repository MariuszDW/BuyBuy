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
    
    var unitText: String {
        get { unit?.symbol ?? "" }
        set { unit = ShoppingItemUnit(string: newValue) }
    }
    
    var totalPrice: Double? {
        guard let price = price, let quantity = quantity else {
            return nil
        }
        return price * quantity
    }
    
    var totalPriceString: String? {
        guard let totalPriceValue = totalPrice else {
            return nil
        }
        let formatter = NumberFormatter.localizedDecimal(minFractionDigits: 2, maxFractionDigits: 2)
        return formatter.string(from: totalPriceValue as NSNumber) ?? "\(totalPriceValue)"
    }

    init(id: UUID = UUID(), order: Int, listID: UUID, name: String, note: String = "", status: ShoppingItemStatus, price: Double? = nil, quantity: Double? = nil, unit: ShoppingItemUnit? = nil) {
        self.id = id
        self.order = order
        self.listID = listID
        self.name = name
        self.note = note
        self.status = status
        self.price = price
        self.quantity = quantity
        self.unit = unit
    }
    
    mutating func prepareToSave() {
        name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        note = note.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
