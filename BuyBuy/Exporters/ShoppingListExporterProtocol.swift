//
//  ShoppingListExporterProtocol.swift
//  BuyBuy
//
//  Created by MDW on 16/06/2025.
//

import Foundation

protocol ShoppingListExporterProtocol {
    func export(shoppingList: ShoppingList) -> String
}
