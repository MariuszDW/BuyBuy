//
//  NumberFormatter+Extensions.swift
//  BuyBuy
//
//  Created by MDW on 27/05/2025.
//

import Foundation

extension NumberFormatter {
    static let priceMinPrecision = 2
    static let priceMaxPrecision = 2
    static let quantityMinPrecision = 0
    static let quantityMaxPrecision = 2
    
    static func price(minPrecision: Int = NumberFormatter.priceMinPrecision,
                      maxPrecision: Int = NumberFormatter.priceMaxPrecision) -> NumberFormatter {
        localizedDecimal(minFractionDigits: minPrecision,
                         maxFractionDigits: maxPrecision)
    }
    
    static func quantity(minPrecision: Int = NumberFormatter.quantityMinPrecision,
                         maxPrecision: Int = NumberFormatter.quantityMaxPrecision) -> NumberFormatter {
        localizedDecimal(minFractionDigits: minPrecision,
                         maxFractionDigits: maxPrecision)
    }
    
    static func localizedDecimal(minFractionDigits: Int = 0, maxFractionDigits: Int = 2) -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = minFractionDigits
        formatter.maximumFractionDigits = maxFractionDigits
        return formatter
    }
}
