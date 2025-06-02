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
    
    func openShoppingListSettings(_ list: BuyBuy.ShoppingList, isNew: Bool, onDismiss: @escaping () -> Void) {
        // TODO: implement...
    }
    
    func openShoppingItemDetails(_ item: BuyBuy.ShoppingItem, isNew: Bool, onDismiss: @escaping () -> Void) {
        // TODO: implement...
    }
    
    func openAbout() {
        // TODO: implement...
    }
    
    func openAppSettings() {
        // TODO: implement...
    }
    
    func openLoyaltyCardList() {
        // TODO: implement...
    }
    
    func back() {
        backBlock?()
    }
}
