//
//  MessageShoppingListExporter.swift
//  BuyBuy
//
//  Created by MDW on 29-12-2025.
//

import Foundation

struct MessageShoppingListExporter: ShoppingListExporterProtocol {
    var textEncoding: TextEncoding = .default
    
    var title: Bool = true
    var itemNote: Bool = true
    var itemQuantity: Bool = true
    var itemPricePerUnit: Bool = true
    var itemTotalPrice: Bool = true
    var exportInfo: Bool = false

    func export(shoppingList: ShoppingList) -> Data? {
        // list title
        var result = title == true ? String(localized: "shopping") + " - " + shoppingList.name + "\n\n" : ""
        
        // list note
        if let note = shoppingList.note, !note.isEmpty {
            result += "\(note)\n"
        }
        
        let items = shoppingList.items(for: .pending)
        
        // separator
        if !result.isEmpty && !items.isEmpty {
            result += "----------------\n\n"
        }
        
        // items
        for item in items {
            // item name
            var line = "\(item.name)"
            
            // item quantity
            if itemQuantity, let quantity = item.quantityWithUnit {
                line += " - \(quantity)"
            }
            
            line += "\n"
            
            // item note
            if itemNote, !item.note.isEmpty {
                line += "\(item.note)\n"
            }
            
            result += (line + "\n")
        }
        
        return result.data(using: textEncoding.stringEncoding, allowLossyConversion: true)
    }
}
