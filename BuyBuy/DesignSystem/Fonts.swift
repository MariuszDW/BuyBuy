//
//  Fonts.swift
//  BuyBuy
//
//  Created by MDW on 14/05/2025.
//

import SwiftUI

extension Font {
    static func regularDynamic(style: Font.TextStyle) -> Font {
        .system(style, design: .default)
    }
    
    static func boldDynamic(style: Font.TextStyle) -> Font {
        .system(style, design: .default).weight(.bold)
    }

    static func titleDynamic(style: Font.TextStyle) -> Font {
        .system(style, design: .rounded).weight(.semibold)
    }
    
    static func regularMonospaced(style: Font.TextStyle) -> Font {
        .system(style, design: .monospaced)
    }
    
    static func boldMonospaced(style: Font.TextStyle) -> Font {
        .system(style, design: .monospaced).weight(.bold)
    }
    
    static func titleMonospaced(style: Font.TextStyle) -> Font {
        .system(style, design: .monospaced).weight(.semibold)
    }
}
