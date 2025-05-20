//
//  ShoppingListsRepositoryProtocol.swift
//  BuyBuy
//
//  Created by MDW on 15/05/2025.
//

import Foundation

protocol ShoppingListsRepositoryProtocol {
    // MARK: - Shopping Lists
    func getAllLists() -> [ShoppingList]
    func addList(_ list: ShoppingList)
    func updateList(_ list: ShoppingList)
    func deleteList(with id: UUID)
    func getList(with id: UUID) -> ShoppingList?
    
    // MARK: - Shopping Items
    func getItems(for listID: UUID) -> [ShoppingItem]
    func addItem(_ item: ShoppingItem)
    func updateItem(_ item: ShoppingItem)
    func removeItem(_ item: ShoppingItem)
}
