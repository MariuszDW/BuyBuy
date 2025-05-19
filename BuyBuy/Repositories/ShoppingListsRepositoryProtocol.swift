//
//  ShoppingListsRepositoryProtocol.swift
//  BuyBuy
//
//  Created by MDW on 15/05/2025.
//

import Foundation

protocol ShoppingListsRepositoryProtocol {
    func fetchAllLists() -> [ShoppingList]
    func addList(_ list: ShoppingList)
    func deleteList(with id: UUID)
    func updateList(_ updatedList: ShoppingList)
}
