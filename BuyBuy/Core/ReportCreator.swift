//
//  ReportCreator.swift
//  BuyBuy
//
//  Created by MDW on 13/06/2025.
//

import Foundation
import UIKit
import SwiftUI

@MainActor
final class ReportCreator {
    func buildIssueReportBody(preferences: AppPreferencesProtocol, dynamicTypeSize: DynamicTypeSize, colorScheme: ColorScheme) -> String {
        let device = UIDevice.current
        
        let placeholder = String(localized: "issue_description_placeholder")
        
        let unitSystems = preferences.unitSystems.isEmpty
            ? "none"
            : preferences.unitSystems.map { $0.rawValue }.joined(separator: " + ")
        let dataStorage = preferences.isCloudSyncEnabled ? "iCloud" : "device"
        let isHapticsEnabled = preferences.isHapticsEnabled ? "enabled" : "disabled"
        let installationDate: String = {
            guard let date = preferences.installationDate else { return "none" }
            return ISO8601DateFormatter().string(from: date)
        }()
        let lastCleanupDate: String = {
            guard let date = preferences.lastCleanupDate else { return "none" }
            return ISO8601DateFormatter().string(from: date)
        }()
        let systemFontSize = dynamicTypeSize.description
        let colorScheme = colorScheme == .dark ? "dark" : "light"
        
        let appName = Bundle.main.appName()
        let appVersion = Bundle.main.appVersion(build: true)
        let appReleaseDate: String = {
            guard let releaseDate = Bundle.main.appReleaseDate() else { return "" }
            return releaseDate.localizedString(dateStyle: .medium, timeStyle: .none)
        }()
        let deviceName = device.name
        let systemName = device.systemName
        let systemVersion = device.systemVersion
        let locale = Locale.current.identifier
        let freeDiskSpace = formattedFreeDiskSpace()
        let reportDate = ISO8601DateFormatter().string(from: Date())
        
        return """
        \(placeholder)
        
        ---- Application Settings ----
        Unit systems: \(unitSystems)
        Data storage: \(dataStorage)
        Haptics: \(isHapticsEnabled)
        Installation date: \(installationDate)
        Last cleanup date: \(lastCleanupDate)
        System font size: \(systemFontSize)
        Color scheme: \(colorScheme)

        ---- Technical Info ----
        Application name: \(appName)
        Application version: \(appVersion) (\(appReleaseDate))
        System version: \(systemName) \(systemVersion)
        Device name: \(deviceName)
        Locale: \(locale)
        Free disk space: \(freeDiskSpace)
        Report date: \(reportDate)
        """
    }
    
    private func getFreeDiskSpace() -> Int64? {
        let homeDirectory = NSHomeDirectory()
        do {
            let attributes = try FileManager.default.attributesOfFileSystem(forPath: homeDirectory)
            if let freeSize = attributes[.systemFreeSize] as? NSNumber {
                return freeSize.int64Value
            } else {
                return nil
            }
        } catch {
            print("Error retrieving free disk space: \(error.localizedDescription)")
            return nil
        }
    }
    
    private func formattedFreeDiskSpace() -> String {
        guard let freeBytes = getFreeDiskSpace() else { return "unknown" }
        
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useMB, .useGB, .useTB]
        formatter.countStyle = .file
        formatter.includesUnit = true
        
        return formatter.string(fromByteCount: freeBytes)
    }
}
