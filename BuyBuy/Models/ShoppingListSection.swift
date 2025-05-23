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
        switch status {
        case .pending: .bbItemPendingImage
        case .purchased: .bbItemPurchasedImage
        case .inactive: .bbItemInactiveImage
        }
    }
    
    var color: Color {
        switch status {
        case .pending: .bbListSectionPendingColor
        case .purchased: .bbListSectionPurchasedColor
        case .inactive: .bbListSectionInactiveColor
        }
    }
}
