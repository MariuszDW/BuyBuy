//
//  ShoppingListSection.swift
//  BuyBuy
//
//  Created by MDW on 19/05/2025.
//

import Foundation
import SwiftUI

struct ShoppingListSection: Hashable  {
    let status: ShoppingItemStatus
    var isCollapsed: Bool = false
    
    init(status: ShoppingItemStatus) {
        self.status = status
    }
    
    var localizedTitle: String {
        switch status {
        case .pending: String(localized: "items_pending")
        case .purchased: String(localized: "items_purchased")
        case .inactive: String(localized: "items_inactive")
        }
    }
    
    var image: Image {
        status.image
    }
    
    var color: Color {
        status.color
    }
}
