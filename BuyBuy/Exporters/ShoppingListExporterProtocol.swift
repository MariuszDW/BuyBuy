//
//  ShoppingListExporterProtocol.swift
//  BuyBuy
//
//  Created by MDW on 16/06/2025.
//

import Foundation

protocol ShoppingListExporterProtocol {
    var textEncoding: TextEncoding { get set }
    func export(shoppingList: ShoppingList) -> Data?
}
