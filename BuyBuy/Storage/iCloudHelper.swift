//
//  iCloudHelper.swift
//  BuyBuy
//
//  Created by MDW on 19/06/2025.
//

import Foundation

struct iCloudHelper {
    static func ubiquityContainerURL(for folderName: String) -> URL? {
        guard let containerURL = FileManager.default.url(forUbiquityContainerIdentifier: AppConstants.iCloudContainerIdentifier) else {
            print("❌ iCloud container \(AppConstants.iCloudContainerIdentifier) not available")
            return nil
        }

        let documentsURL = containerURL.appendingPathComponent("Documents", isDirectory: true)
        let folderURL = documentsURL.appendingPathComponent(folderName, isDirectory: true)

        if !FileManager.default.fileExists(atPath: folderURL.path) {
            do {
                try FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true)
                print("✅ Created iCloud folder at \(folderURL.path)")
            } catch {
                print("❌ Failed to create iCloud folder: \(error)")
                return nil
            }
        }

        return folderURL
    }
}
