//
//  AppPreferences.swift
//  BuyBuy
//
//  Created by MDW on 15/06/2025.
//

import Foundation

@MainActor
final class AppPreferences: AppPreferencesProtocol {
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    private enum Keys {
        static let lastCleanupDate = "last_cleanup_date"
        static let metricUnitsEnabled = "metric_units_enabled"
        static let imperialUnitsEnabled = "imperial_units_enabled"
        static let isStartupCleaningAllowed = "is_startup_cleaning_allowed" // TODO: to powinno sie inaczej nazywac, moze firstAppInit i inaczej byc obslugiwane
        static let isCloudSyncEnabled = "is_cloud_sync_enabled"
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

    var isStartupCleaningAllowed: Bool {
        get { (defaults.object(forKey: Keys.isStartupCleaningAllowed) as? Bool) ?? true }
        set { defaults.set(newValue, forKey: Keys.isStartupCleaningAllowed) }
    }

    var isCloudSyncEnabled: Bool {
        get { (defaults.object(forKey: Keys.isCloudSyncEnabled) as? Bool) ?? false }
        set { defaults.set(newValue, forKey: Keys.isCloudSyncEnabled) }
    }

    var unitSystems: [MeasureUnitSystem] {
        MeasureUnitSystem.allCases.filter {
            switch $0 {
            case .metric: return isMetricUnitsEnabled
            case .imperial: return isImperialUnitsEnabled
            }
        }
    }
}
