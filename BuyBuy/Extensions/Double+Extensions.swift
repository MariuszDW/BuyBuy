//
//  Double+Extensions.swift
//  BuyBuy
//
//  Created by MDW on 01/06/2025.
//

import Foundation

extension Double {
    var priceFormat: String {
        let formatter = NumberFormatter.price()
        return formatter.string(for: self) ?? "\(self)"
    }
    
    var quantityFormat: String {
        let formatter = NumberFormatter.quantity()
        return formatter.string(for: self) ?? "\(self)"
    }
    
    var priceRound: Double {
        self.rounded(to: NumberFormatter.priceMaxPrecision)
    }
    
    var quantityRound: Double {
        self.rounded(to: NumberFormatter.quantityMaxPrecision)
    }
    
    func rounded(to places: Int) -> Double {
        let multiplier = pow(10, Double(places))
        return (self * multiplier).rounded() / multiplier
    }
}
