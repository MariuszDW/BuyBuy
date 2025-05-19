//
//  ShoppingListSection.swift
//  BuyBuy
//
//  Created by MDW on 19/05/2025.
//

import Foundation
import SwiftUI

enum ShoppingListSection {
    case pending
    case purchased
    case inactive
    
    var title: String {
        switch self {
        case .pending: "Pending"
        case .purchased: "Purchased"
        case .inactive: "Inactive"
        }
    }
    
    var systemImage: String {
        switch self {
        case .pending: "hourglass"
        case .purchased: "checkmark"
        case .inactive: "zzz"
        }
    }
    
    var color: Color {
        switch self {
        case .pending: .orange
        case .purchased: .green
        case .inactive: .red
        }
    }
    
    var itemStatus: ShoppingItemStatus {
        switch self {
        case .pending: .pending
        case .purchased: .purchased
        case .inactive: .inactive
        }
    }
}
