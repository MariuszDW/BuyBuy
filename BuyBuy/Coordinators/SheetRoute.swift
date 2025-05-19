//
//  SheetRoute.swift
//  BuyBuy
//
//  Created by MDW on 17/05/2025.
//

import SwiftUI

enum SheetRoute: Identifiable, Equatable {
    case shoppingListSettings(ShoppingList, Bool)
    case about

    var id: String {
        switch self {
        case .shoppingListSettings:
            return "shoppingListSettings"
        case .about:
            return "about"
        }
    }

    static func == (lhs: SheetRoute, rhs: SheetRoute) -> Bool {
        lhs.id == rhs.id
    }
}
