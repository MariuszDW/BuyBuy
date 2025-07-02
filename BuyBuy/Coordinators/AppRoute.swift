//
//  AppRoute.swift
//  BuyBuy
//
//  Created by MDW on 14/05/2025.
//

import SwiftUI

enum AppRoute: Hashable {
    case shoppingLists
    case shoppingList(UUID)
    case deletedItems
    case appSettings
    case loyaltyCards
    case about
}
