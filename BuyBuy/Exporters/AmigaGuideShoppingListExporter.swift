//
//  AmigaGuideShoppingListExporter.swift
//  BuyBuy
//
//  Created by MDW on 17/06/2025.
//

import Foundation

struct AmigaGuideShoppingListExporter: ShoppingListExporterProtocol {
    var textEncoding: TextEncoding = .default

    var itemNote: Bool = true
    var itemQuantity: Bool = true
    var itemPricePerUnit: Bool = true
    var itemTotalPrice: Bool = true
    var exportInfo: Bool = true

    func export(shoppingList: ShoppingList) -> Data? {
        let appName = Bundle.main.appName()
        let appVersion = Bundle.main.appVersion(suffix: true)
        
        var result = ""

        // file header
        result += """
        @DATABASE "\(shoppingList.name)"
        @AUTHOR "\(appName)"
        @$VER: \(appName) \(appVersion)
        @INDEX Main

        """

        // list node
        result += "\n@Node Main \"\(shoppingList.name)\"\n\n"

        // list name
        result += "@{b}\(shoppingList.name)@{ub}\n\n"

        // list note
        if let note = shoppingList.note, !note.isEmpty {
            result += "\(String(localized: "note")):\n"
            result += "\(note)\n\n"
        }

        // sections by item status
        for status in ShoppingItemStatus.allCases {
            let items = shoppingList.items(for: status)
            guard !items.isEmpty else { continue }

            // section title
            let sectionTitle = ShoppingListSection(status: status).localizedTitle.uppercased()
            result += "@{b}\(sectionTitle)@{ub}\n\n"

            for item in items {
                // item link
                let itemLink = itemGUID(for: item)
                result += "- @{\"\(item.name)\" link \(itemLink)}\n"
            }

            result += "\n"
        }
        
        if exportInfo {
            result += "\n\n@{i}\(Self.exportInfoText())@{ui}\n"
        }
        
        result += "@EndNode\n\n"

        // item nodes
        for status in ShoppingItemStatus.allCases {
            let items = shoppingList.items(for: status)
            for item in items {
                let itemNode = itemGUID(for: item)
                result += "@Node \(itemNode) \"\(item.name)\"\n\n"

                // item name
                result += "@{b}\(item.name)@{ub}\n\n"

                // item status
                result += "\(String(localized: "status")): \(item.status.localizedName)\n\n"

                // item note
                if itemNote, !item.note.isEmpty {
                    result += "\(String(localized: "note")):\n"
                    result += "\(item.note)\n\n"
                }

                // item quantity
                if itemQuantity, let quantity = item.quantityWithUnit {
                    result += "\(String(localized: "quantity")): \(quantity)\n"
                }

                // item price per unit
                if itemPricePerUnit, let price = item.price?.priceFormat {
                    result += "\(String(localized: "price_per_unit")): \(price)\n"
                }

                // item total price
                if itemTotalPrice, let totalPrice = item.totalPrice?.priceFormat {
                    result += "\(String(localized: "total_price")): \(totalPrice)\n"
                }

                // back to list button
                result += "\n@{\"\(String(localized: "back"))\" link Main}\n"
                result += "@EndNode\n\n"
            }
        }
        
        return result.data(using: textEncoding.stringEncoding, allowLossyConversion: true)
    }

    // helper to create valid node names
    private func itemGUID(for item: ShoppingItem) -> String {
        "Item_\(item.id.uuidString.replacingOccurrences(of: "-", with: ""))"
    }
}
