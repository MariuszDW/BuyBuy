//
//  Array+UUID.swift
//  BuyBuy
//
//  Created by MDW on 16/05/2025.
//

import Foundation

extension UUID {
    static func unique(in UUIDs: [UUID]?) -> UUID {
        var newUUID = UUID()
        if let UUIDs = UUIDs {
            while UUIDs.contains(newUUID) {
                newUUID = UUID()
            }
        }
        return newUUID
    }
}
