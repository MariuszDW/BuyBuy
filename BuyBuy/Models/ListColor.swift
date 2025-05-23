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
        case .blue: .bb.list.blue
        case .brown: .bb.list.brown
        case .cyan: .bb.list.cyan
        case .gray: .bb.list.gray
        case .green: .bb.list.green
        case .indigo: .bb.list.indigo
        case .magenta: .bb.list.magenta
        case .orange: .bb.list.orange
        case .pink: .bb.list.pink
        case .purple: .bb.list.purple
        case .red: .bb.list.red
        case .yellow: .bb.list.yellow
        }
    }
}
