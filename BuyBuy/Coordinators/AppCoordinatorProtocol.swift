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
    func openShoppingListSettings(_ list: ShoppingList, isNew: Bool, onDismiss: @escaping () -> Void)
    func openShoppingItemDetails(_ item: ShoppingItem, isNew: Bool, onDismiss: @escaping () -> Void)
    func openAbout()
    func openAppSettings()
    func openLoyaltyCardList()
    func openLoyaltyCardPreview(with imageID: String)
    func back()
}
