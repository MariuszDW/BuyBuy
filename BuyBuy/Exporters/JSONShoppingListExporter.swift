//
//  JSONShoppingListExporter.swift
//  BuyBuy
//
//  Created by MDW on 17/06/2025.
//

import Foundation

struct ShoppingListData: Codable {
    let name: String
    let note: String?
    let itemStatuses: [String: [ItemData]]

    enum CodingKeys: String, CodingKey {
        case name, note
        case itemStatuses = "item_statuses"
    }

    struct ItemData: Codable {
        let name: String
        let note: String?
        let quantity: QuantityData?
        let pricePerUnit: Double?
        let totalPrice: Double?

        enum CodingKeys: String, CodingKey {
            case name, note, quantity
            case pricePerUnit = "price_per_unit"
            case totalPrice = "total_price"
        }

        struct QuantityData: Codable {
            let value: Double?
            let unit: String?
        }
    }
}

struct JSONShoppingListExporter: ShoppingListExporterProtocol {
    var textEncoding: TextEncoding = .utf8

    var itemNote: Bool = true
    var itemQuantity: Bool = true
    var itemPricePerUnit: Bool = true
    var itemTotalPrice: Bool = true

    func export(shoppingList: ShoppingList) -> Data? {
        let encoding = textEncoding.stringEncoding

        var itemStatusesDict = [String: [ShoppingListData.ItemData]]()

        for status in ShoppingItemStatus.allCases {
            let items = shoppingList.items(for: status)
            guard !items.isEmpty else { continue }

            let exportedItems: [ShoppingListData.ItemData] = items.map { item in
                let quantityData: ShoppingListData.ItemData.QuantityData? = {
                    guard itemQuantity else { return nil }
                    if item.quantity == nil && item.unit?.symbol == nil {
                        return nil
                    }
                    return ShoppingListData.ItemData.QuantityData(
                        value: item.quantity,
                        unit: item.unit?.symbol.cleaned(toEncoding: encoding)
                    )
                }()

                return ShoppingListData.ItemData(
                    name: item.name.cleaned(toEncoding: encoding),
                    note: itemNote && !item.note.isEmpty ? item.note.cleaned(toEncoding: encoding) : nil,
                    quantity: quantityData,
                    pricePerUnit: itemPricePerUnit ? item.price : nil,
                    totalPrice: itemTotalPrice ? item.totalPrice : nil
                )
            }

            itemStatusesDict[status.rawValue] = exportedItems
        }

        let jsonList = ShoppingListData(
            name: shoppingList.name.cleaned(toEncoding: encoding),
            note: (shoppingList.note?.isEmpty == false) ? shoppingList.note!.cleaned(toEncoding: encoding) : nil,
            itemStatuses: itemStatusesDict
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        do {
            return try encoder.encode(jsonList)
        } catch {
            print("JSON encoding error: \(error)")
            return nil
        }
    }
}
