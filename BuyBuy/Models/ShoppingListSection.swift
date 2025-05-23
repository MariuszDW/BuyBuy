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
    
    var title: String {
        switch status {
        case .pending: "Pending"
        case .purchased: "Purchased"
        case .inactive: "Inactive"
        }
    }
    
    var image: Image {
        status.image
    }
    
    var color: Color {
        status.color
    }
}
