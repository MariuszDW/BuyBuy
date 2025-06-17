//
//  Color+Extensions.swift
//  BuyBuy
//
//  Created by MDW on 17/06/2025.
//

import SwiftUI

extension Color {
    var hexString: String? {
        let uiColor = UIColor(self)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0

        guard uiColor.getRed(&red, green: &green, blue: &blue, alpha: nil) else {
            return nil
        }

        let r = Int(red * 255)
        let g = Int(green * 255)
        let b = Int(blue * 255)

        return String(format: "#%02X%02X%02X", r, g, b)
    }
}
