//
//  AppPreferences.swift
//  BuyBuy
//
//  Created by MDW on 15/06/2025.
//

import Foundation

final class AppPreferences {
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    private enum Keys {
        static let lastCleanupDate = "lastCleanupDate"
    }

    var lastCleanupDate: Date? {
        get {
            defaults.object(forKey: Keys.lastCleanupDate) as? Date
        }
        set {
            defaults.set(newValue, forKey: Keys.lastCleanupDate)
        }
    }
}
