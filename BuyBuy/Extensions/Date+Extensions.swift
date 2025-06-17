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
                         locale: Locale = Locale.current,
                         timeZone: TimeZone = .current) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = dateStyle
        formatter.timeStyle = timeStyle
        formatter.locale = locale
        formatter.timeZone = timeZone
        return formatter.string(from: self)
    }
    
    func iso8601UTCString() -> String {
        let formatter = ISO8601DateFormatter()
        formatter.timeZone = TimeZone(identifier: "UTC")
        return formatter.string(from: self)
    }
}
