//
//  MockAppCoordinator.swift
//  BuyBuyTests
//
//  Created by MDW on 14/05/2025.
//

import Foundation
import Combine
@testable import BuyBuy

final class MockAppCoordinator: AppCoordinatorProtocol {
    var needRefreshListsPublisher: AnyPublisher<Bool, Never> = Just(false).eraseToAnyPublisher()
    var openListBlock: ((UUID) -> Void)?
    var onBack: (() -> Void)?

    func openList(_ id: UUID) {
        openListBlock?(id)
    }
    
    func resetNeedRefreshListsFlag() {
        // TODO: implement...
    }
    
    func openListSettings(_ list: BuyBuy.ShoppingList, isNew: Bool) {
        // TODO: implement...
    }
    
    func openAbout() {
        // TODO: implement...
    }
    
    func openSettings() {
        // TODO: implement...
    }

    func back() {
        onBack?()
    }
}
