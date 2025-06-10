//
//  String+Extensions.swift
//  BuyBuy
//
//  Created by MDW on 10/06/2025.
//

import Foundation

extension String {
    var priceDouble: Double? {
        let formatter = NumberFormatter.price()
        return formatter.number(from: self)?.doubleValue
    }
    
    var quantityDouble: Double? {
        let formatter = NumberFormatter.quantity()
        return formatter.number(from: self)?.doubleValue
    }
}
