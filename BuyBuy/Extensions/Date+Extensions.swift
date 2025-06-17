//
//  Date+Extensions.swift
//  BuyBuy
//
//  Created by MDW on 17/06/2025.
//

import Foundation

extension Date {
    func localizedString(dateStyle: DateFormatter.Style = .medium,
                         timeStyle: DateFormatter.Style = .none,
                         locale: Locale = Locale.current) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = dateStyle
        formatter.timeStyle = timeStyle
        formatter.locale = locale
        return formatter.string(from: self)
    }
}
