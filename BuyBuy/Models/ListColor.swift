//
//  ListColor.swift
//  BuyBuy
//
//  Created by MDW on 16/05/2025.
//

import SwiftUI

enum ListColor: String, CaseIterable {
    case red = "ListColorRed"
    case orange = "ListColorOrange"
    case yellow = "ListColorYellow"
    case green = "ListColorGreen"
    case blue = "ListColorBlue"
    case purple = "ListColorPurple"
    case pink = "ListColorPink"
    case gray = "ListColorGray"
    
    static var `default`: ListColor { .blue }

    var color: Color {
        Color(self.rawValue)
    }
}
