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
        _ = installationDate // ensure installationDate is set
    }

    var installationDate: Date {
        guard let date = preferences.installationDate else {
            let now = Date()
            preferences.installationDate = now
            return now
        }
        return date
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

    var lastTipJarShownDate: Date {
        get {
            preferences.lastTipJarShownDate ?? installationDate
        }
        set {
            preferences.lastTipJarShownDate = newValue
        }
    }
    
    func updateTipReminder() {
        let now = Date()
        let lastShown = lastTipJarShownDate

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
