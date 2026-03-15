//
//  ShoppingItemUnit.swift
//  BuyBuy
//
//  Created by MDW on 25/05/2025.
//

import Foundation

struct ShoppingItemUnit: Codable, Hashable {
    let predefined: MeasuredUnit?
    let custom: String?
    
    init?(string: String?) {
        guard let trimmed = string?.trimmingCharacters(in: .whitespacesAndNewlines), !trimmed.isEmpty else {
            return nil
        }

        if let predefined = MeasuredUnit.from(symbol: trimmed) {
            self.predefined = predefined
            self.custom = nil
        } else {
            self.predefined = nil
            self.custom = trimmed
        }
    }
    
    init(_ unit: MeasuredUnit) {
        self.predefined = unit
        self.custom = nil
    }

    var symbol: String {
        predefined?.symbol ?? custom ?? ""
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
