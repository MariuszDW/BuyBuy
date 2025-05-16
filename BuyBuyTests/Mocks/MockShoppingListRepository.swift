//
//  MockShoppingListRepository.swift
//  BuyBuyTests
//
//  Created by MDW on 15/05/2025.
//

import Foundation
@testable import BuyBuy

final class MockShoppingListRepository: ShoppingListRepositoryProtocol {
    var fetchListHandler: (() -> ShoppingList)?
    var addItemHandler: ((ShoppingItem) -> Void)?
    var updateItemHandler: ((ShoppingItem) -> Void)?
    var removeItemHandler: ((UUID) -> Void)?

    func fetchList() -> ShoppingList? {
        fetchListHandler?()
    }

    func addItem(_ item: ShoppingItem) {
        addItemHandler?(item)
    }

    func updateItem(_ item: ShoppingItem) {
        updateItemHandler?(item)
    }

    func removeItem(with id: UUID) {
        removeItemHandler?(id)
    }
}
