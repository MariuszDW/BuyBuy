//
//  PlainTextShoppingListExporter.swift
//  BuyBuy
//
//  Created by MDW on 16/06/2025.
//

import Foundation

struct PlainTextShoppingListExporter: ShoppingListExporterProtocol {
    func export(shoppingList: ShoppingList) -> String {
        var result = "Lista zakupów: \(shoppingList.name)\n"
        
        if let note = shoppingList.note, !note.isEmpty {
            result += "Notatka: \(note)\n"
        }
        
        result += "\n"

        for status in ShoppingItemStatus.allCases {
            let items = shoppingList.items(for: status)
            guard !items.isEmpty else { continue }

            result += "== \(status.localizedName.uppercased()) ==\n"
            
            for item in items {
                var line = "• \(item.name)"
                if let qty = item.quantityWithUnit {
                    line += " [\(qty)]"
                }
                if !item.note.isEmpty {
                    line += " — \(item.note)"
                }
                result += line + "\n"
            }

            result += "\n"
        }

        return result
    }
}
