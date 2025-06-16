//
//  AppPreferences.swift
//  BuyBuy
//
//  Created by MDW on 15/06/2025.
//

import Foundation

final class AppPreferences: AppPreferencesProtocol {
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    private enum Keys {
        static let lastCleanupDate = "last_cleanup_date"
        
        static let metricUnitsEnabled = "metric_units_enabled"
        static let imperialUnitsEnabled = "imperial_units_enabled"
    }

    var lastCleanupDate: Date? {
        get { defaults.object(forKey: Keys.lastCleanupDate) as? Date }
        set { defaults.set(newValue, forKey: Keys.lastCleanupDate) }
    }
    
    var isMetricUnitsEnabled: Bool {
        get { (defaults.object(forKey: Keys.metricUnitsEnabled) as? Bool) ?? true }
        set { defaults.set(newValue, forKey: Keys.metricUnitsEnabled) }
    }
    
    var isImperialUnitsEnabled: Bool {
        get { (defaults.object(forKey: Keys.imperialUnitsEnabled) as? Bool) ?? true }
        set { defaults.set(newValue, forKey: Keys.imperialUnitsEnabled) }
    }
    
    // MARK: - Useful getters
    
    var unitSystems: [MeasureUnitSystem] {
        MeasureUnitSystem.allCases.filter {
            switch $0 {
            case .metric: return isMetricUnitsEnabled
            case .imperial: return isImperialUnitsEnabled
            }
        }
    }
}
