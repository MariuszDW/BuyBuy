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
    var order: Int
    var icon: ListIcon
    var color: ListColor
    var items: [ShoppingItem] = []
    
    init(id: UUID = UUID(), name: String = "", note: String? = nil, items: [ShoppingItem] = [], order: Int, icon: ListIcon = .default, color: ListColor = .default) {
        self.id = id
        self.name = name
        self.note = note
        self.order = order
        self.icon = icon
        self.color = color
        self.items = items
    }
    
    mutating func prepareToSave() {
        name = name.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var iconRawValue: String {
        get { icon.rawValue }
        set { icon = ListIcon(rawValue: newValue) ?? .default }
    }
    
    var colorRawValue: String {
        get { color.rawValue }
        set { color = ListColor(rawValue: newValue) ?? .default }
    }
    
    func items(for status: ShoppingItemStatus) -> [ShoppingItem] {
        let sortedItems = items
            .filter { $0.status == status }
            .sorted {
                if $0.order == $1.order {
                    return $0.id.uuidString < $1.id.uuidString
                }
                return $0.order < $1.order
            }
        
//        print("aaaa: ------")
//        sortedItems.forEach { print("aaaa: \($0.name), \($0.status), \($0.order)") }
        
        return sortedItems
    }
    
    func item(with id: UUID) -> ShoppingItem? {
        items.first(where: { $0.id == id})
    }
    
    func totalPrice(for status: ShoppingItemStatus) -> Double {
        let filteredItems = items.filter { $0.status == status }
        let total = filteredItems.reduce(0.0) { partialResult, item in
            partialResult + (item.totalPrice ?? 0)
        }
        return total
    }
    
    func containsItemsWithPrice() -> Bool {
        items.contains(where: { $0.price != nil })
    }
}
