//
//  SheetRoute.swift
//  BuyBuy
//
//  Created by MDW on 17/05/2025.
//

import SwiftUI
import StoreKit

enum SheetRoute {
    case shoppingListSettings(ShoppingList, Bool)
    case shoppingItemDetails(ShoppingItem, Bool)
    case shoppingItemImage([String], Int)
    case loyaltyCardPreview(String?)
    case loyaltyCardDetails(LoyaltyCard, Bool)
    case shoppingListSelector(itemIDToRestore: UUID)
    case shoppingListExport(ShoppingList)
    case documentExporter(ExportedData)
    case tipJar
    case thankYou(transaction: StoreKit.Transaction)
}
