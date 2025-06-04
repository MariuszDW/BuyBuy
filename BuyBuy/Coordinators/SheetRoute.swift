//
//  SheetRoute.swift
//  BuyBuy
//
//  Created by MDW on 17/05/2025.
//

import SwiftUI

enum SheetRoute {
    case shoppingListSettings(ShoppingList, Bool)
    case shoppintItemDetails(ShoppingItem, Bool)
    case shoppingItemImage(String)
    case about
    case loyaltyCardPreview(String?)
    case loyaltyCardDetails(LoyaltyCard, Bool)
}
