//
//  ReportCreator.swift
//  BuyBuy
//
//  Created by MDW on 13/06/2025.
//

import Foundation
import UIKit

@MainActor
final class ReportCreator {
    func buildIssueReportBody() -> String {
        let appVersion = Bundle.main.appVersion()
        let device = UIDevice.current
        
        let deviceName = device.name
        let systemName = device.systemName
        let systemVersion = device.systemVersion
        let locale = Locale.current.identifier
        let timestamp =  ISO8601DateFormatter().string(from: Date())
        let freeDiskSpace = formattedFreeDiskSpace()
        
        return """
        Please describe the issue here...

        --- Technical Info ---
        Application Version: \(appVersion)
        System Version: \(systemName) \(systemVersion)
        Device Name: \(deviceName)
        Locale: \(locale)
        Timestamp: \(timestamp)
        Free Disk Space: \(freeDiskSpace)
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
