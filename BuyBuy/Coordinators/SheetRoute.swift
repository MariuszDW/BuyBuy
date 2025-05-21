//
//  SheetRoute.swift
//  BuyBuy
//
//  Created by MDW on 17/05/2025.
//

import SwiftUI

enum SheetRoute: Identifiable {
    case shoppingListSettings(ShoppingList, Bool, onSave: () -> Void)
    case shoppintItemDetails(ShoppingItem, Bool)
    case about

    var id: String {
        switch self {
        case .shoppingListSettings:
            return "shoppingListSettings"
        case .shoppintItemDetails:
            return "shoppingItemDetails"
        case .about:
            return "about"
        }
    }
}
