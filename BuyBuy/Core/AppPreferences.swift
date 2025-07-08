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
        // main preference
        static let lastCleanupDate = "last_cleanup_date"
        static let metricUnitsEnabled = "metric_units_enabled"
        static let imperialUnitsEnabled = "imperial_units_enabled"
        static let isCloudSyncEnabled = "is_cloud_sync_enabled"
        
        // tips
        static let tipCounts = "act_tip_counts"
        static let lastTipDate = "act_last_tip_date"
        static let lastTipJarShownDate = "act_last_tipjar_shown_date"
        
        // user activity tracker
        static let installationDate = "act_installation_date"
        static let totalActiveTime = "act_total_active_time"
    }

    var lastCleanupDate: Date? {
        get {
            defaults.object(forKey: Keys.lastCleanupDate) as? Date
        }
        set {
            defaults.set(newValue, forKey: Keys.lastCleanupDate)
        }
    }

    var isMetricUnitsEnabled: Bool {
        get {
            (defaults.object(forKey: Keys.metricUnitsEnabled) as? Bool) ?? true
        }
        set {
            defaults.set(newValue, forKey: Keys.metricUnitsEnabled)
        }
    }

    var isImperialUnitsEnabled: Bool {
        get {
            (defaults.object(forKey: Keys.imperialUnitsEnabled) as? Bool) ?? true
        }
        set {
            defaults.set(newValue, forKey: Keys.imperialUnitsEnabled)
        }
    }

    var isCloudSyncEnabled: Bool {
        get {
            (defaults.object(forKey: Keys.isCloudSyncEnabled) as? Bool) ?? false
        }
        set {
            defaults.set(newValue, forKey: Keys.isCloudSyncEnabled)
        }
    }

    var unitSystems: [MeasureUnitSystem] {
        MeasureUnitSystem.allCases.filter {
            switch $0 {
            case .metric: return isMetricUnitsEnabled
            case .imperial: return isImperialUnitsEnabled
            }
        }
    }
    
    // MARK: - User Activity Tracker
    
    var installationDate: Date? {
        get {
            defaults.object(forKey: Keys.installationDate) as? Date
        }
        set {
            defaults.set(newValue, forKey: Keys.installationDate)
        }
    }

    var totalActiveTime: TimeInterval {
        get {
            defaults.double(forKey: Keys.totalActiveTime)
        }
        set {
            defaults.set(newValue, forKey: Keys.totalActiveTime)
        }
    }
    
    var tipCounts: [String: Int] {
        get {
            (defaults.object(forKey: Keys.tipCounts) as? [String: Int]) ?? [:]
        }
        set {
            defaults.set(newValue, forKey: Keys.tipCounts)
        }
    }

    func tipCount(for tipID: String) -> Int {
        tipCounts[tipID] ?? 0
    }

    func setTipCount(_ count: Int, for tipID: String) {
        var counts = tipCounts
        counts[tipID] = count
        tipCounts = counts
    }
    
    var lastTipDate: Date? {
        get {
            defaults.object(forKey: Keys.lastTipDate) as? Date
        }
        set {
            defaults.set(newValue, forKey: Keys.lastTipDate)
        }
    }
    
    var lastTipJarShownDate: Date? {
        get {
            defaults.object(forKey: Keys.lastTipJarShownDate) as? Date
        }
        set {
            defaults.set(newValue, forKey: Keys.lastTipJarShownDate)
        }
    }
}
