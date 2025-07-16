//
//  DynamicTypeSize+Extensions.swift
//  BuyBuy
//
//  Created by MDW on 16/07/2025.
//

import SwiftUI

extension DynamicTypeSize {
    var description: String {
        switch self {
        case .xSmall: return "xSmall"
        case .small: return "small"
        case .medium: return "medium"
        case .large: return "large"
        case .xLarge: return "xLarge"
        case .xxLarge: return "xxLarge"
        case .xxxLarge: return "xxxLarge"
        case .accessibility1: return "accessibility1"
        case .accessibility2: return "accessibility2"
        case .accessibility3: return "accessibility3"
        case .accessibility4: return "accessibility4"
        case .accessibility5: return "accessibility5"
        default: return "unknown"
        }
    }
}
