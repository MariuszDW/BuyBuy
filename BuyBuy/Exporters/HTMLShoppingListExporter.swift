//
//  HTMLShoppingListExporter.swift
//  BuyBuy
//
//  Created by MDW on 17/06/2025.
//

import Foundation

struct HTMLShoppingListExporter: ShoppingListExporterProtocol {
    var textEncoding: TextEncoding = .default
    
    var itemNote: Bool = true
    var itemQuantity: Bool = true
    var itemPricePerUnit: Bool = true
    var itemTotalPrice: Bool = true
    var exportInfo: Bool = true

    func export(shoppingList: ShoppingList) -> Data? {
        var html = """
        <!DOCTYPE html>
        <html>
        <head>
          <meta charset="\(textEncoding.charsetName)">
          <title>\(shoppingList.name)</title>
        </head>
        <body>
        """

        // list name with color
        let titleColorHex = shoppingList.color.color.hexString ?? "#000000"
        html += "<h2><font color=\"\(titleColorHex)\">\(shoppingList.name)</font></h2>\n"

        // list note
        if let note = shoppingList.note, !note.isEmpty {
            html += "<p>\(note)</p>\n"
        }
        
        // separator
        html += "<hr>\n"

        for status in ShoppingItemStatus.allCases {
            let items = shoppingList.items(for: status)
            guard !items.isEmpty else { continue }

            // category of items with color
            let statusColorHex = status.color.hexString ?? "#000000"
            let categoryTitle = status.localizedCategoryName.uppercased()
            html += "<h3><font color=\"\(statusColorHex)\">\(categoryTitle)</font></h3>\n"
            html += "<ul>\n"

            for item in items {
                // item name
                html += "<li><b>\(item.name)</b><br/>\n"

                // item note
                if itemNote, !item.note.isEmpty {
                    html += "\(String(localized: "note")): <i>\(item.note)</i><br/>\n"
                }

                // item quantity
                if itemQuantity, let quantity = item.quantityWithUnit {
                    html += "\(String(localized: "quantity")): <code>\(quantity)</code><br/>\n"
                }

                // item price per unit
                if itemPricePerUnit, let price = item.price?.priceFormat {
                    html += "\(String(localized: "price_per_unit")): <code>\(price)</code><br/>\n"
                }

                // item total price
                if itemTotalPrice, let totalPrice = item.totalPrice?.priceFormat {
                    html += "\(String(localized: "total_price")): <code>\(totalPrice)</code><br/>\n"
                }

                html += "</li>\n"
            }

            html += "</ul>\n"
        }
        
        if exportInfo {
            html += "<hr><p><i>\(Self.exportInfoText())</i></p>"
        }

        html += "</body></html>"

        return html.data(using: textEncoding.stringEncoding, allowLossyConversion: true)
    }
}
