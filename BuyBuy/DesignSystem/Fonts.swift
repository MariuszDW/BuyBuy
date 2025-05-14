//
//  Fonts.swift
//  BuyBuy
//
//  Created by MDW on 14/05/2025.
//

import SwiftUI

enum AppFont {
    static func regular(size: CGFloat) -> Font {
        .system(size: size, weight: .regular)
    }

    static func bold(size: CGFloat) -> Font {
        .system(size: size, weight: .bold)
    }

    static func title(size: CGFloat) -> Font {
        .system(size: size, weight: .semibold, design: .rounded)
    }
}
