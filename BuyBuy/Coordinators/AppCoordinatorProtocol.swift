//
//  AppCoordinatorProtocol.swift
//  BuyBuy
//
//  Created by MDW on 14/05/2025.
//

import Foundation
import Combine

protocol AppCoordinatorProtocol: ObservableObject {
    func openShoppingList(_ id: UUID)
    func openAppSettings()
    func openLoyaltyCardList()
    func openShoppingListSettings(_ list: ShoppingList, isNew: Bool, onDismiss: (() -> Void)?)
    func openShoppingItemDetails(_ item: ShoppingItem, isNew: Bool, onDismiss: (() -> Void)?)
    func openShoppingItemImage(with imageID: String, onDismiss: (() -> Void)?)
    func openLoyaltyCardPreview(with imageID: String, onDismiss: (() -> Void)?)
    func openAbout()
    func closeTopSheet()
    func closeAllSheets()
    func back()
}
