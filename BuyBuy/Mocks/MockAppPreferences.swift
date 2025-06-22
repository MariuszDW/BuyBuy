//
//  MockAppPreferences.swift
//  BuyBuy
//
//  Created by MDW on 22/06/2025.
//

import Foundation

@MainActor
final class MockAppPreferences: AppPreferencesProtocol {
    var lastCleanupDate: Date? = Date()
    var isMetricUnitsEnabled: Bool = true
    var isImperialUnitsEnabled: Bool = true
    var isStartupCleaningAllowed: Bool = true
    var isCloudSyncEnabled: Bool = false
    
    var unitSystems: [MeasureUnitSystem] {
        MeasureUnitSystem.allCases.filter {
            switch $0 {
            case .metric: return isMetricUnitsEnabled
            case .imperial: return isImperialUnitsEnabled
            }
        }
    }
    
    init(lastCleanupDate: Date? = Date(),
         metricUnitsEnabled: Bool = true,
         imperialUnitsEnabled: Bool = true,
         startupCleaningAllowed: Bool = true,
         cloudSyncEnabled: Bool = false) {
        self.lastCleanupDate = lastCleanupDate
        self.isMetricUnitsEnabled = metricUnitsEnabled
        self.isImperialUnitsEnabled = imperialUnitsEnabled
        self.isStartupCleaningAllowed = startupCleaningAllowed
        self.isCloudSyncEnabled = cloudSyncEnabled
    }
}
