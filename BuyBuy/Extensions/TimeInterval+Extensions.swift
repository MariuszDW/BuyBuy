//
//  TimeInterval+Extensions.swift
//  BuyBuy
//
//  Created by MDW on 28/06/2025.
//

import Foundation

extension TimeInterval {
    var formattedDuration: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.day, .hour, .minute, .second]
        formatter.unitsStyle = .full
        formatter.zeroFormattingBehavior = .dropAll
        return formatter.string(from: self) ?? "0 seconds"
    }
}
