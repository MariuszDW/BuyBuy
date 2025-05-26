//
//  ShoppingItemUnit.swift
//  BuyBuy
//
//  Created by MDW on 25/05/2025.
//

import Foundation

// Wrapper do jednostki z customową obsługą
struct ShoppingItemUnit: Codable, Hashable {
    let predefined: MeasuredUnit?
    let custom: String?
    
    init?(string: String?) {
        guard let string = string else { return nil }
        
        if let unitBySymbol = MeasuredUnit.from(symbol: string) {
            self.predefined = unitBySymbol
            self.custom = nil
        } else {
            self.predefined = nil
            self.custom = string
        }
    }

    var symbol: String {
        if let unit = predefined {
            return unit.symbol
        } else {
            return custom ?? ""
        }
    }
    
    @MainActor
    func format(value: Double, fractionDigits: Int = 2, showUnit: Bool = true) -> String {
        if let unit = predefined {
            return unit.format(value: value, fractionDigits: fractionDigits, withUnit: showUnit)
        }

        let formattedValue = String(format: "%.\(fractionDigits)f", value)

        if showUnit, let customUnit = custom {
            return "\(formattedValue) \(customUnit)"
        } else {
            return formattedValue
        }
    }
}
