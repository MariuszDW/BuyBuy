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
    
    /// Returns a version of the string sanitized for the specified character encoding,
    /// by removing or replacing characters that are not supported by that encoding.
    /// If the string is already compatible with the encoding, it is returned unchanged.
    func cleaned(toEncoding encoding: String.Encoding) -> String {
        if let _ = self.data(using: encoding, allowLossyConversion: false) {
            return self
        }
        if let data = self.data(using: encoding, allowLossyConversion: true),
           let cleaned = String(data: data, encoding: encoding) {
            return cleaned
        }
        return ""
    }
}
