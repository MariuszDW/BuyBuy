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

    func export(shoppingList: ShoppingList) -> Data? {
        // list name
        var result = "\(shoppingList.name)\n"
        
        // list note
        if let note = shoppingList.note, !note.isEmpty {
            result += "\(note)\n"
        }

        result += "\n"

        for status in ShoppingItemStatus.allCases {
            let items = shoppingList.items(for: status)
            guard !items.isEmpty else { continue }

            // category of items
            result += "==== \(status.localizedName.uppercased()) ====\n\n"
            
            for item in items {
                // item name
                var line = "- \(item.name)\n"
                
                // item note
                if itemNote, !item.note.isEmpty {
                    line += "  \(item.note)\n"
                }
                
                // item quantity
                if itemQuantity, let quantity = item.quantityWithUnit {
                    line += "  \(quantity)\n"
                }
                
                // item price and total price
                let price = itemPricePerUnit ? item.price : nil
                let totalPrice = itemTotalPrice ? item.totalPrice : nil
                
                let priceString = price?.priceFormat
                let totalPriceString = totalPrice?.priceFormat
                
                let priceLine: String
                switch (priceString, totalPriceString) {
                case let (p?, t?):
                    priceLine = "\(p) (\(t))"
                case let (p?, nil):
                    priceLine = p
                case let (nil, t?):
                    priceLine = t
                default:
                    priceLine = ""
                }
                
                if !priceLine.isEmpty {
                    line += "  \(priceLine)\n"
                }
                
                result += line + "\n"
            }
        }

        return result.data(using: textEncoding.stringEncoding, allowLossyConversion: true)
    }
}
