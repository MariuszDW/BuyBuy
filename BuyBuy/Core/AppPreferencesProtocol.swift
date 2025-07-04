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
    var unitSystems: [MeasureUnitSystem] { get }
}
