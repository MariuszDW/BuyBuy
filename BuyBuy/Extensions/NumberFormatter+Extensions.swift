//
//  NumberFormatter+Extensions.swift
//  BuyBuy
//
//  Created by MDW on 27/05/2025.
//

import Foundation

extension NumberFormatter {
    static func localizedDecimal(minFractionDigits: Int = 0, maxFractionDigits: Int = 2) -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = minFractionDigits
        formatter.maximumFractionDigits = maxFractionDigits
        return formatter
    }
}
