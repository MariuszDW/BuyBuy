//
//  MockAppCoordinator.swift
//  BuyBuyTests
//
//  Created by MDW on 14/05/2025.
//

import Foundation
@testable import BuyBuy

final class MockAppCoordinator: AppCoordinatorProtocol {
    var onGoToShoppingListDetails: ((UUID) -> Void)?
    var onBack: (() -> Void)?

    func goToShoppingListDetails(_ id: UUID) {
        onGoToShoppingListDetails?(id)
    }

    func back() {
        onBack?()
    }
}
