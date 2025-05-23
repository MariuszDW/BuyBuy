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
    var openListBlock: ((UUID) -> Void)?
    var onBack: (() -> Void)?
    
    func openList(_ id: UUID) {
        openListBlock?(id)
    }
    
    func openShoppingList(_ id: UUID) {
        // TODO: Implement...
    }
    
    func openShoppingListSettings(_ list: BuyBuy.ShoppingList, isNew: Bool, onSave: @escaping () -> Void) {
        // TODO: implement...
    }
    
    func openShoppingItemDetails(_ item: BuyBuy.ShoppingItem, isNew: Bool, onSave: @escaping () -> Void) {
        // TODO: implement...
    }
    
    func openAbout() {
        // TODO: implement...
    }
    
    func openAppSettings() {
        // TODO: implement...
    }

    func back() {
        onBack?()
    }
}
