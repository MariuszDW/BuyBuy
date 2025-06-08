//
//  Double+Extensions.swift
//  BuyBuy
//
//  Created by MDW on 01/06/2025.
//

import Foundation

extension Double {
    var priceFormat: String {
        let formatter = NumberFormatter.priceFormatter()
        return formatter.string(for: self) ?? "\(self)"
    }
    
    var quantityFormat: String {
        let formatter = NumberFormatter.localizedDecimal()
        return formatter.string(for: self) ?? "\(self)"
    }
}
