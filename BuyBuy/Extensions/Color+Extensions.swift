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
    
    func hsb(hue: Double = 0, saturation: Double = 0, brightness: Double = 0) -> Color {
        let ui = UIColor(self)
        
        var h: CGFloat = 0
        var s: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        ui.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        
        let newH = CGFloat((Double(h) + hue).truncatingRemainder(dividingBy: 1.0))
        let newS = CGFloat(min(max(Double(s) + saturation, 0), 1))
        let newB = CGFloat(min(max(Double(b) + brightness, 0), 1))
        
        return Color(
            hue: Double(newH),
            saturation: Double(newS),
            brightness: Double(newB),
            opacity: Double(a)
        )
    }
}
