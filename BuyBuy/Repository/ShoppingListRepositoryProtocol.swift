//
//  ShoppingListRepositoryProtocol.swift
//  BuyBuy
//
//  Created by MDW on 15/05/2025.
//

import Foundation

protocol ShoppingListRepositoryProtocol {
    func fetchList(by id: UUID) -> ShoppingList?
    func fetchAllLists() -> [ShoppingList]
}
