//
//  SheetRoute.swift
//  BuyBuy
//
//  Created by MDW on 17/05/2025.
//

import SwiftUI

enum SheetRoute: Identifiable, Equatable {
    case listSettings(ListSettingsViewModel)
    case about

    var id: String {
        switch self {
        case .listSettings:
            return "listSettings"
        case .about:
            return "about"
        }
    }

    static func == (lhs: SheetRoute, rhs: SheetRoute) -> Bool {
        lhs.id == rhs.id
    }
}
