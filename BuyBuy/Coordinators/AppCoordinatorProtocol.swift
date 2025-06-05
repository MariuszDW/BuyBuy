//
//  AppCoordinatorProtocol.swift
//  BuyBuy
//
//  Created by MDW on 14/05/2025.
//

import Foundation
import Combine

protocol AppCoordinatorProtocol: ObservableObject {
    var eventPublisher: PassthroughSubject<AppEvent, Never> { get }
    func sendEvent(_ event: AppEvent)
    
    func openShoppingList(_ id: UUID)
    func openAppSettings()
    func openLoyaltyCardList()
    func openShoppingListSettings(_ list: ShoppingList, isNew: Bool, onDismiss: ((SheetRoute) -> Void)?)
    func openShoppingItemDetails(_ item: ShoppingItem, isNew: Bool, onDismiss: ((SheetRoute) -> Void)?)
    func openShoppingItemImage(with imageID: String, onDismiss: ((SheetRoute) -> Void)?)
    func openLoyaltyCardPreview(with imageID: String?, onDismiss: ((SheetRoute) -> Void)?)
    func openLoyaltyCardDetails(_ card: LoyaltyCard, isNew: Bool, onDismiss: ((SheetRoute) -> Void)?)
    func openAbout()
    func closeTopSheet()
    func closeAllSheets()
    func back()
}
