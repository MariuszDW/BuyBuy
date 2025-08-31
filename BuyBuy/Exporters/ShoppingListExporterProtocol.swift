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
    
    var exportInfo: Bool { get set }
    
    func export(shoppingList: ShoppingList) -> Data?
}

extension ShoppingListExporterProtocol {
    static func exportInfoText() -> String {
        let appName = Bundle.main.appName()
        let appVersion = Bundle.main.appVersion()
        let dateString = Date.now.localizedString(dateStyle: .short,
                                                  timeStyle: .medium,
                                                  locale: .current,
                                                  timeZone: TimeZone(identifier: "UTC")!) + " UTC"
        return String(format: String(localized: "generated_by"), appName, appVersion, dateString)
    }
}
