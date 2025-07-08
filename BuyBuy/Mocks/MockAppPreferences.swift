//
//  MockAppPreferences.swift
//  BuyBuy
//
//  Created by MDW on 22/06/2025.
//

import Foundation

@MainActor
final class MockAppPreferences: AppPreferencesProtocol {
    var installationDate: Date?
    var totalActiveTime: TimeInterval = 0
    
    var tipCounts: [String : Int]
    var lastTipDate: Date?
    var lastTipJarShownDate: Date?
    
    var lastCleanupDate: Date? = Date()
    var isMetricUnitsEnabled: Bool = true
    var isImperialUnitsEnabled: Bool = true
    var isStartupCleaningAllowed: Bool = true
    var isCloudSyncEnabled: Bool = false
    var isHapticsEnabled: Bool = true
    
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
         cloudSyncEnabled: Bool = false,
         hapticsEnabled: Bool = true,
         totalActiveTime: TimeInterval = 0,
         tipCounts: [String : Int] = MockAppPreferences.mockTipCounts) {
        self.lastCleanupDate = lastCleanupDate
        self.isMetricUnitsEnabled = metricUnitsEnabled
        self.isImperialUnitsEnabled = imperialUnitsEnabled
        self.isStartupCleaningAllowed = startupCleaningAllowed
        self.isCloudSyncEnabled = cloudSyncEnabled
        self.isHapticsEnabled = hapticsEnabled
        
        self.installationDate = Date()
        self.totalActiveTime = totalActiveTime
        
        self.tipCounts = tipCounts
        self.lastTipDate = nil
        self.lastTipJarShownDate = nil
    }
    
    func tipCount(for tipID: String) -> Int {
        tipCounts[tipID] ?? 0
    }
    
    func setTipCount(_ count: Int, for tipID: String) {
        tipCounts[tipID] = count
    }
}

extension MockAppPreferences {
    static let mockTipCounts: [String: Int] = {
        let values = [1, 3, 0]
        return Dictionary(uniqueKeysWithValues: zip(AppConstants.tipIDs, values))
    }()
}
