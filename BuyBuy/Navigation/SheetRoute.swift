//
//  SheetRoute.swift
//  BuyBuy
//
//  Created by MDW on 17/05/2025.
//

import SwiftUI
import StoreKit
import CloudKit

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
    case sharingController(share: CKShare, title: String)
    case appInitialSetup
    
    func isSameKind(as other: SheetRoute) -> Bool {
        switch (self, other) {
        case (.shoppingListSettings, .shoppingListSettings),
            (.shoppingItemDetails, .shoppingItemDetails),
            (.shoppingItemImage, .shoppingItemImage),
            (.loyaltyCardPreview, .loyaltyCardPreview),
            (.loyaltyCardDetails, .loyaltyCardDetails),
            (.shoppingListSelector, .shoppingListSelector),
            (.shoppingListExport, .shoppingListExport),
            (.documentExporter, .documentExporter),
            (.tipJar, .tipJar),
            (.thankYou, .thankYou),
            (.sharingController, .sharingController),
            (.appInitialSetup, .appInitialSetup):
            return true
        default:
            return false
        }
    }
}
