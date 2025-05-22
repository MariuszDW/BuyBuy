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
    func openShoppingListSettings(_ list: ShoppingList, isNew: Bool, onSave: @escaping () -> Void)
    func openShoppingItemDetails(_ item: ShoppingItem, isNew: Bool)
    func openAbout()
    func openAppSettings()
    func back()
}
