//
//  Asset.swift
//  BuyBuy
//
//  Created by MDW on 20/05/2025.
//

import SwiftUI

struct BBColor {
    static let accent = Color("Accent")
    static let background = Color("Background")
    static let selection = Color("Selection")
    static let grey50 = Color("Grey50")
    static let grey75 = Color("Grey75")
    static let grey85 = Color("Grey85")
    static let grey90 = Color("Grey90")
    
    enum sheet {
        static let background = Color("SheetBackground")
        enum section {
            static let background = Color("SheetSectionBackground")
            static let primaryText = Color("SheetSectionPrimaryText")
            static let secondaryText = Color("SheetSectionSecondaryText")
        }
    }
    
    enum text {
        static let primary = Color("PrimaryText")
        static let secondary = Color("SecondaryText")
    }
    
    enum list {
        static let blue = Color("ListBlue")
        static let brown = Color("ListBrown")
        static let cyan = Color("ListCyan")
        static let gray = Color("ListGray")
        static let green = Color("ListGreen")
        static let indigo = Color("ListIndigo")
        static let magenta = Color("ListMagenta")
        static let orange = Color("ListOrange")
        static let pink = Color("ListPink")
        static let purple = Color("ListPurple")
        static let red = Color("ListRed")
        static let yellow = Color("ListYellow")
    }
    
    enum itemStatus {
        static let inactive = Color("ItemStatusInactive")
        static let pending = Color("ItemStatusPending")
        static let purchased = Color("ItemStatusPurchased")
    }
}

extension Color {
    static let bb = BBColor.self
}
