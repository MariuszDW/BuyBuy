//
//  UserActivityTracker.swift
//  BuyBuy
//
//  Created by MDW on 04/07/2025.
//

import Foundation

@MainActor
final class UserActivityTracker: UserActivityTrackerProtocol {
    private var preferences: AppPreferencesProtocol
    
    var shouldShowTipReminder: Bool = false
    
    init(preferences: AppPreferencesProtocol) {
        self.preferences = preferences
    }

    var installationDate: Date? {
        preferences.installationDate
    }

    var lastTipDate: Date? {
        preferences.lastTipDate
    }
    
    func tipCount(for tipID: String) -> Int {
        preferences.tipCount(for: tipID)
    }
    
    var totalTipsCount: Int {
        preferences.tipCounts.values.reduce(0, +)
    }
    
    func incrementTipCount(for tipID: String) {
        let current = preferences.tipCount(for: tipID)
        preferences.setTipCount(current + 1, for: tipID)
        preferences.lastTipDate = Date()
    }

    var lastTipJarShownDate: Date? {
        get {
            preferences.lastTipJarShownDate
        }
        set {
            preferences.lastTipJarShownDate = newValue
        }
    }
    
    func updateTipReminder() {
        let now = Date()
        
        guard let lastShown = lastTipJarShownDate else {
            preferences.lastTipJarShownDate = installationDate ?? now
            return
        }

        let hasTipped = lastTipDate != nil
        let intervalDays = hasTipped
            ? AppConstants.tipReminderIntervalTippedDays
            : AppConstants.tipReminderIntervalNeverTippedDays

        guard let daysSinceLastShown = Calendar.current.dateComponents([.day], from: lastShown, to: now).day else {
            shouldShowTipReminder = false
            return
        }

        shouldShowTipReminder = daysSinceLastShown >= intervalDays
    }
}
