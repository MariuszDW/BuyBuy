//
//  Fonts.swift
//  BuyBuy
//
//  Created by MDW on 14/05/2025.
//

import SwiftUI

enum AppFont {
//    static func regular(size: CGFloat) -> Font {
//        .system(size: size, weight: .regular)
//    }
//
//    static func bold(size: CGFloat) -> Font {
//        .system(size: size, weight: .bold)
//    }
//
//    static func title(size: CGFloat) -> Font {
//        .system(size: size, weight: .semibold, design: .rounded)
//    }
    
    static func regularDynamic(style: Font.TextStyle) -> Font {
        .system(style, design: .default)
    }
    
    static func boldDynamic(style: Font.TextStyle) -> Font {
        .system(style, design: .default).weight(.bold)
    }

    static func titleDynamic(style: Font.TextStyle) -> Font {
        .system(style, design: .rounded).weight(.semibold)
    }
}
