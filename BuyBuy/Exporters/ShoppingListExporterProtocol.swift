//
//  ShoppingListExporterProtocol.swift
//  BuyBuy
//
//  Created by MDW on 16/06/2025.
//

import Foundation

protocol ShoppingListExporterProtocol {
    var textEncoding: TextEncoding { get set }
    var itemNote: Bool { get set }
    var itemQuantity: Bool { get set }
    var itemPricePerUnit: Bool { get set }
    var itemTotalPrice: Bool { get set }
    
    func export(shoppingList: ShoppingList) -> Data?
}
