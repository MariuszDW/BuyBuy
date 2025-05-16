//
//  Array+UUID.swift
//  BuyBuy
//
//  Created by MDW on 16/05/2025.
//

import Foundation

extension UUID {
    static func unique(in existingUUIDs: [UUID]) -> UUID {
        var newUUID = UUID()
        while existingUUIDs.contains(newUUID) {
            newUUID = UUID()
        }
        return newUUID
    }
}
