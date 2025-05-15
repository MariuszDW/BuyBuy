//
//  MockShoppingListRepository.swift
//  BuyBuyTests
//
//  Created by MDW on 15/05/2025.
//

import Foundation
@testable import BuyBuy

final class MockShoppingListRepository: ShoppingListRepositoryProtocol {

    var fetchListHandler: ((UUID) -> ShoppingList?)?
    var fetchAllListsHandler: (() -> [ShoppingList])?

    func fetchList(by id: UUID) -> ShoppingList? {
        fetchListHandler?(id)
    }

    func fetchAllLists() -> [ShoppingList] {
        fetchAllListsHandler?() ?? []
    }
}
