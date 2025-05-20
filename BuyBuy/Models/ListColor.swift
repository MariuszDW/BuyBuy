//
//  ListColor.swift
//  BuyBuy
//
//  Created by MDW on 16/05/2025.
//

import SwiftUI

enum ListColor: String, CaseIterable {
    case blue
    case brown
    case cyan
    case gray
    case green
    case indigo
    case magenta
    case orange
    case pink
    case purple
    case red
    case yellow
    
    static var `default`: ListColor { .blue }

    var color: Color {
        switch self {
        case .blue: .bbListBlue
        case .brown: .bbListBrown
        case .cyan: .bbListCyan
        case .gray: .bbListGray
        case .green: .bbListGreen
        case .indigo: .bbListIndigo
        case .magenta: .bbListMagenta
        case .orange: .bbListOrange
        case .pink: .bbListPink
        case .purple: .bbListPurple
        case .red: .bbListRed
        case .yellow: .bbListYellow
        }
    }
}
