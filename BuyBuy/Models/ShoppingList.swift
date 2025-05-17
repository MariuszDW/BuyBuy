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
    var items: [ShoppingItem]
    var order: Int
    var icon: ListIcon = .default
    var color: ListColor = .default
    
    var iconRawValue: String {
        get { icon.rawValue }
        set { icon = ListIcon(rawValue: newValue) ?? .default }
    }

    var colorRawValue: String {
        get { color.rawValue }
        set { color = ListColor(rawValue: newValue) ?? .default }
    }
}
