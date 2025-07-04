//
//  MockUserActivityTracker.swift
//  BuyBuy
//
//  Created by MDW on 04/07/2025.
//

import Foundation

@MainActor
final class MockUserActivityTracker: UserActivityTrackerProtocol {
    var tipCounts: [String : Int] = [:]
    
    var installationDate: Date = Date()
    
    var lastTipDate: Date? = nil
    
    func tipCount(for tipID: String) -> Int {
        tipCounts[tipID] ?? 0
    }
    
    var totalTipsCount: Int = 0
    
    func incrementTipCount(for tipID: String) {
        let tipCount = tipCounts[tipID] ?? 0
        tipCounts[tipID] = tipCount + 1
    }
    
    var lastTipJarShownDate: Date = Date()
}
