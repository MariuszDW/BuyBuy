//
//  AppCoordinatorProtocol.swift
//  BuyBuy
//
//  Created by MDW on 14/05/2025.
//

import Foundation
import Combine

protocol AppCoordinatorProtocol: ObservableObject {
    func openList(_ id: UUID)
    func openListSettings(_ list: ShoppingList, isNew: Bool, onSave: @escaping () -> Void)
    func openItemDetails(_ item: ShoppingItem, isNew: Bool)
    func openAbout()
    func openSettings()
    func back()
}
