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
    var lastActiveStartDate: Date? = nil
    
    init(preferences: AppPreferencesProtocol) {
        self.preferences = preferences
    }

    var installationDate: Date? {
        preferences.installationDate
    }
    
    var totalActiveTime: TimeInterval {
        return preferences.totalActiveTime
    }
    
    var totalActiveHours: Double {
        totalActiveTime / 3600
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
        
        // Proceed only if the user has used the app for more than 30 minutes in total.
        guard preferences.totalActiveTime > 1800 else {
            shouldShowTipReminder = false
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
    
    func appDidEnterForeground() {
        lastActiveStartDate = Date()
    }

    func appDidEnterBackground() {
        guard let start = lastActiveStartDate else { return }
        let duration = Date().timeIntervalSince(start)
        preferences.totalActiveTime += duration
        lastActiveStartDate = nil
    }
}
