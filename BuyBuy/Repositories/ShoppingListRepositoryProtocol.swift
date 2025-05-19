//
//  ShoppingListRepositoryProtocol.swift
//  BuyBuy
//
//  Created by MDW on 15/05/2025.
//

import Foundation

protocol ShoppingListRepositoryProtocol {
    func getItems() -> ShoppingList?
    func addItem(_ item: ShoppingItem)
    func updateItem(_ item: ShoppingItem)
    func removeItem(with id: UUID)
}
