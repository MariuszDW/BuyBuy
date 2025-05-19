//
//  ShoppingList.swift
//  BuyBuy
//
//  Created by MDW on 15/05/2025.
//

import Foundation

struct ShoppingList: Identifiable, Hashable {
    let id: UUID
    var name: String
    var note: String?
    var items: [ShoppingItem]
    var order: Int
    var icon: ListIcon
    var color: ListColor
    
    init(id: UUID = UUID(), name: String = "", note: String? = nil, items: [ShoppingItem] = [], order: Int, icon: ListIcon = .default, color: ListColor = .default) {
        self.id = id
        self.name = name
        self.note = note
        self.items = items
        self.order = order
        self.icon = icon
        self.color = color
    }
    
    var iconRawValue: String {
        get { icon.rawValue }
        set { icon = ListIcon(rawValue: newValue) ?? .default }
    }

    var colorRawValue: String {
        get { color.rawValue }
        set { color = ListColor(rawValue: newValue) ?? .default }
    }
    
    mutating func prepareToSave() {
        name = name.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func countItems(withStatus status: ShoppingItemStatus) -> Int {
        return items.filter { $0.status == status }.count
    }
    
    func countItems(withoutStatus status: ShoppingItemStatus) -> Int {
        return items.filter { $0.status != status }.count
    }
}
