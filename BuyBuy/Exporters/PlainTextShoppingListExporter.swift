//
//  PlainTextShoppingListExporter.swift
//  BuyBuy
//
//  Created by MDW on 16/06/2025.
//

import Foundation

struct PlainTextShoppingListExporter: ShoppingListExporterProtocol {
    var textEncoding: TextEncoding = .default
    
    var itemNote: Bool = true
    var itemQuantity: Bool = true
    var itemPricePerUnit: Bool = true
    var itemTotalPrice: Bool = true
    var exportInfo: Bool = true

    func export(shoppingList: ShoppingList) -> Data? {
        // list name
        var result = "\(shoppingList.name)\n"
        
        // list note
        if let note = shoppingList.note, !note.isEmpty {
            result += "\(note)\n"
        }

        // separator
        result += "----------------\n\n"

        for status in ShoppingItemStatus.allCases {
            let items = shoppingList.items(for: status)
            guard !items.isEmpty else { continue }

            // category of items
            let categoryTitle = status.localizedCategoryName.uppercased()
            result += "\n==== \(categoryTitle) ====\n\n"
            
            for item in items {
                // item name
                var line = "- \(item.name)\n"
                
                // item note
                if itemNote, !item.note.isEmpty {
                    line += "  \(String(localized: "note")): \(item.note)\n"
                }
                
                // item quantity
                if itemQuantity, let quantity = item.quantityWithUnit {
                    line += "  \(String(localized: "quantity")): \(quantity)\n"
                }
                
                // item price per unit
                if itemPricePerUnit, let price = item.price?.priceFormat {
                    line += "  \(String(localized: "price_per_unit")): \(price)\n"
                }

                // item total price
                if itemTotalPrice, let totalPrice = item.totalPrice?.priceFormat {
                    line += "  \(String(localized: "total_price")): \(totalPrice)\n"
                }
                
                result += (line + "\n")
            }
        }
        
        if exportInfo {
            result += "\n----------------\n\n"
            result += (Self.exportInfoText() + "\n")
        }

        return result.data(using: textEncoding.stringEncoding, allowLossyConversion: true)
    }
}
