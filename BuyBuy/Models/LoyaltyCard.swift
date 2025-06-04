//
//  LoyaltyCard.swift
//  BuyBuy
//
//  Created by MDW on 02/06/2025.
//

import Foundation

struct LoyaltyCard: Identifiable {
    let id: UUID
    var name: String
    var imageID: String?
    
    mutating func prepareToSave() {
        name = name.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
