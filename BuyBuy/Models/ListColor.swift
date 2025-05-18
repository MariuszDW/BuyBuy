//
//  ListColor.swift
//  BuyBuy
//
//  Created by MDW on 16/05/2025.
//

import SwiftUI

enum ListColor: String, CaseIterable {
    case blue = "ListColorBlue"
    case brown = "ListColorBrown"
    case cyan = "ListColorCyan"
    case gray = "ListColorGray"
    case green = "ListColorGreen"
    case indigo = "ListColorIndigo"
    case magenta = "ListColorMagenta"
    case orange = "ListColorOrange"
    case pink = "ListColorPink"
    case purple = "ListColorPurple"
    case red = "ListColorRed"
    case yellow = "ListColorYellow"
    
    static var `default`: ListColor { .blue }

    var color: Color {
        Color(self.rawValue)
    }
}
