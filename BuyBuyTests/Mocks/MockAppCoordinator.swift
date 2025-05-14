//
//  MockAppCoordinator.swift
//  BuyBuyTests
//
//  Created by MDW on 14/05/2025.
//

import Foundation
@testable import BuyBuy

final class MockAppCoordinator: AppCoordinatorProtocol {
    private(set) var goToShoppingListCalled = false
    private(set) var backCalled = false

    func goToShoppingList() {
        goToShoppingListCalled = true
    }

    func back() {
        backCalled = true
    }
}
