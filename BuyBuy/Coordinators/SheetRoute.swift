//
//  SheetRoute.swift
//  BuyBuy
//
//  Created by MDW on 17/05/2025.
//

import SwiftUI

enum SheetRoute: Identifiable {
    case shoppingListSettings(ShoppingList, Bool)
    case shoppintItemDetails(ShoppingItem, Bool)
    case shoppingItemImage(String)
    case about
    case loyaltyCardPreview(String?)

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
            return "loyaltyCardPreview-\(imageID ?? UUID().uuidString)"
        }
    }
}
