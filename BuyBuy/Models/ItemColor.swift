//
//  ItemColor.swift
//  BuyBuy
//
//  Created by MDW on 16/05/2025.
//

import SwiftUI

enum ItemColor: String, CaseIterable {
    case red = "ItemColorRed"
    case orange = "ItemColorOrange"
    case yellow = "ItemColorYellow"
    case green = "ItemColorGreen"
    case blue = "ItemColorBlue"
    case purple = "ItemColorPurple"
    case pink = "ItemColorPink"
    case gray = "ItemColorGray"
    
    static var `default`: ItemColor { .blue }

    var color: Color {
        Color(self.rawValue)
    }
}
