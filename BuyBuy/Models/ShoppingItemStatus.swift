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
    
    var checkBoxImage: Image {
        switch self {
        case .pending: return Image(systemName: "circle")
        case .purchased: return Image(systemName: "inset.filled.circle")
        case .inactive: return Image(systemName: "pause.circle")
        }
    }
    
    var image: Image {
        switch self {
        case .pending: return Image(systemName: "hourglass")
        case .purchased: return Image(systemName: "checkmark")
        case .inactive: return Image(systemName: "zzz")
        }
    }
    
    var color: Color {
        switch self {
        case .pending: .bb.itemStatus.pending
        case .purchased: .bb.itemStatus.purchased
        case .inactive: .bb.itemStatus.inactive
        }
    }
    
    func toggled() -> ShoppingItemStatus {
        switch self {
        case .pending: return .purchased
        case .purchased, .inactive: return .pending
        }
    }
}
