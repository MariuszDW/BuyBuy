//
//  AppPreferencesProtocol.swift
//  BuyBuy
//
//  Created by MDW on 16/06/2025.
//

import Foundation

@MainActor
protocol AppPreferencesProtocol {
    var isMetricUnitsEnabled: Bool { get set }
    var isImperialUnitsEnabled: Bool { get set }
    var lastCleanupDate: Date? { get set }
    var isCloudSyncEnabled: Bool { get set }
    var isHapticsEnabled: Bool { get set }
    var lastAppVersion: String { get set }
    var unitSystems: [MeasureUnitSystem] { get }
    
    // User activity tracker
    var installationDate: Date? { get set }
    var totalActiveTime: TimeInterval { get set }
    
    var tipCounts: [String: Int] { get set }
    func tipCount(for tipID: String) -> Int
    func setTipCount(_ count: Int, for tipID: String)
    
    var lastTipDate: Date? { get set }
    var lastTipJarShownDate: Date? { get set }
    
    var legacyCloudImages: Bool { get set }
    var legacyDeviceImages: Bool { get set }
}
