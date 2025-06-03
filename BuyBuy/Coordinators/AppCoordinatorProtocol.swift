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
    func openShoppingListSettings(_ list: ShoppingList, isNew: Bool, onDismiss: @escaping () -> Void)
    func openShoppingItemDetails(_ item: ShoppingItem, isNew: Bool, onDismiss: @escaping () -> Void)
    func openShoppingItemImage(with imageID: String, onDismiss: @escaping () -> Void)
    func openLoyaltyCardPreview(with imageID: String, onDismiss: @escaping () -> Void)
    func openAbout(onDismiss: @escaping () -> Void)
    func closeTopSheet()
    func closeAllSheets()
    func back()
}
