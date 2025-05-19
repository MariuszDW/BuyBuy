//
//  ShoppingItemStatus.swift
//  BuyBuy
//
//  Created by MDW on 15/05/2025.
//

import SwiftUI

enum ShoppingItemStatus: String, CaseIterable, Hashable {
    case pending    // Item is yet to be purchased (active).
    case purchased  // Item has been bought (done).
    case inactive   // Item is currently not relevant or temporarily inactive.
    
    var iconName: String {
        switch self {
        case .pending: return "circle"
        case .purchased: return "checkmark.circle.fill"
        case .inactive: return "zzz"
        }
    }
    
    var iconColor: Color {
        switch self {
        case .pending: return .gray
        case .purchased: return .green
        case .inactive: return .gray.opacity(0.5)
        }
    }
    
    func toggled() -> ShoppingItemStatus {
        switch self {
        case .pending: return .purchased
        case .purchased, .inactive: return .pending
        }
    }
}
