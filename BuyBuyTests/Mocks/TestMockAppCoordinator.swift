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
    
    func openShoppingList(_ id: UUID) {
        openShoppingListBlock?(id)
    }
    
    func openAppSettings() {
    }
    
    func openLoyaltyCardList() {
    }
    
    func openShoppingListSettings(_ list: ShoppingList, isNew: Bool, onDismiss: @escaping () -> Void) {
    }
    
    func openShoppingItemDetails(_ item: ShoppingItem, isNew: Bool, onDismiss: @escaping () -> Void) {
    }
    
    func openShoppingItemImage(with imageID: String, onDismiss: @escaping () -> Void) {
    }
    
    func openLoyaltyCardPreview(with imageID: String, onDismiss: @escaping () -> Void) {
    }
    
    func openAbout(onDismiss: @escaping () -> Void) {
    }
    
    func closeTopSheet() {
    }
    
    func closeAllSheets() {
    }
    
    func back() {
        backBlock?()
    }
}
