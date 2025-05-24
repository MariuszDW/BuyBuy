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

    init(id: UUID = UUID(), order: Int, listID: UUID, name: String, note: String = "", status: ShoppingItemStatus) {
        self.id = id
        self.order = order
        self.listID = listID
        self.name = name
        self.note = note
        self.status = status
    }
    
    mutating func prepareToSave() {
        name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        note = note.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
