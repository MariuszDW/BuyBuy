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
    
    var localizedName: String {
        switch self {
        case .pending: return String(localized: "item_pending")
        case .purchased: return String(localized: "item_purchased")
        case .inactive: return String(localized: "item_inactive")
        }
    }
    
    var checkBoxImage: Image {
        return Image(systemName: checkBoxImageName)
    }
    
    var checkBoxImageName: String {
        switch self {
        case .pending: return "circle"
        case .purchased: return "inset.filled.circle"
        case .inactive: return "pause.circle"
        }
    }
    
    var image: Image {
        return Image(systemName: imageSystemName)
    }
    
    var imageSystemName: String {
        switch self {
        case .pending: return "hourglass"
        case .purchased: return "checkmark"
        case .inactive: return "zzz"
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
