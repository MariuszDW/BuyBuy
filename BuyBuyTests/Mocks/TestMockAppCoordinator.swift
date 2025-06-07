//
//  MockAppCoordinator.swift
//  BuyBuyTests
//
//  Created by MDW on 14/05/2025.
//

import Foundation
import Combine
@testable import BuyBuy

final class TestMockAppCoordinator: AppCoordinatorProtocol {
    var openShoppingListBlock: ((UUID) -> Void)?
    var backBlock: (() -> Void)?
    
    var eventPublisher = PassthroughSubject<BuyBuy.AppEvent, Never>()
    
    func openShoppingList(_ id: UUID) {
        openShoppingListBlock?(id)
    }
    
    func openAppSettings() {
    }
    
    func openLoyaltyCardList() {
    }
    
    func openShoppingListSettings(_ list: ShoppingList, isNew: Bool, onDismiss: ((SheetRoute) -> Void)? = nil) {
    }
    
    func openShoppingItemDetails(_ item: ShoppingItem, isNew: Bool, onDismiss: ((SheetRoute) -> Void)? = nil) {
    }
    
    func openShoppingItemImage(with imageIDs: [String], index: Int, onDismiss: ((SheetRoute) -> Void)? = nil) {
    }
    
    func openLoyaltyCardPreview(with imageID: String?, onDismiss: ((SheetRoute) -> Void)? = nil) {
    }
    
    func openLoyaltyCardDetails(_ card: LoyaltyCard, isNew: Bool, onDismiss: ((SheetRoute) -> Void)? = nil) {
    }
    
    func openAbout() {
    }
    
    func closeTopSheet() {
    }
    
    func closeAllSheets() {
    }
    
    func back() {
        backBlock?()
    }
    
    func sendEvent(_ event: BuyBuy.AppEvent) {
    }
}
