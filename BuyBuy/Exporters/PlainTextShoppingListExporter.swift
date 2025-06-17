//
//  PlainTextShoppingListExporter.swift
//  BuyBuy
//
//  Created by MDW on 16/06/2025.
//

import Foundation

struct PlainTextShoppingListExporter: ShoppingListExporterProtocol {
    var textEncoding: TextEncoding = .default

    func export(shoppingList: ShoppingList) -> Data? {
        var result = "\(shoppingList.name)\n"
        
        if let note = shoppingList.note, !note.isEmpty {
            result += "\(note)\n"
        }

        result += "\n"

        for status in ShoppingItemStatus.allCases {
            let items = shoppingList.items(for: status)
            guard !items.isEmpty else { continue }

            result += "==== \(status.localizedName.uppercased()) ====\n\n"
            
            for item in items {
                var line = "- \(item.name)\n"
                if !item.note.isEmpty {
                    line += "  \(item.note)\n"
                }
                if let quantity = item.quantityWithUnit {
                    line += "  \(quantity)\n"
                }
                if let price = item.price {
                    line += "  \(price.priceFormat)"
                    if let totalPrice = item.totalPrice, totalPrice != price {
                        line += " (\(totalPrice.priceFormat))"
                    }
                    line += "\n"
                }
                result += line + "\n"
            }
        }

        return result.data(using: textEncoding.stringEncoding, allowLossyConversion: true)
    }
}
