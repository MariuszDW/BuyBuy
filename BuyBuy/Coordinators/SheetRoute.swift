//
//  SheetRoute.swift
//  BuyBuy
//
//  Created by MDW on 17/05/2025.
//

import SwiftUI

enum SheetRoute: Identifiable, Equatable {
    case shoppingListSettings(ShoppingList, Bool)
    case shoppintItemDetails(ShoppingItem, Bool)
    case shoppingItemImage(String)
    case about
    case loyaltyCardPreview(String)

    var id: String {
        switch self {
        case let .shoppingListSettings(list, _):
            return "shoppingListSettings-\(list.id.uuidString)"
        case let .shoppintItemDetails(item, _):
            return "shoppingItemDetails-\(item.id.uuidString)"
        case let .shoppingItemImage(imageID):
            return "shoppingItemImage-\(imageID)"
        case .about:
            return "about"
        case let .loyaltyCardPreview(imageID):
            return "loyaltyCardPreview-\(imageID)"
        }
    }

    static func == (lhs: SheetRoute, rhs: SheetRoute) -> Bool {
        switch (lhs, rhs) {
        case let (.shoppingListSettings(l1, b1), .shoppingListSettings(l2, b2)):
            return l1.id == l2.id && b1 == b2
        case let (.shoppintItemDetails(i1, b1), .shoppintItemDetails(i2, b2)):
            return i1.id == i2.id && b1 == b2
        case let (.shoppingItemImage(id1), .shoppingItemImage(id2)):
            return id1 == id2
        case (.about, .about):
            return true
        case let (.loyaltyCardPreview(id1), .loyaltyCardPreview(id2)):
            return id1 == id2
        default:
            return false
        }
    }
}
