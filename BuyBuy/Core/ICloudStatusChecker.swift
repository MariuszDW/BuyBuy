//
//  ICloudStatusChecker.swift
//  BuyBuy
//
//  Created by MDW on 05/07/2025.
//

import Foundation
import CloudKit

enum ICloudStatusError: Error, CustomStringConvertible {
    case notSignedIn
    case iCloudDriveUnavailable
    case cloudKitUnavailable
    case restricted
    case couldNotDetermine
    case ubiquityContainerUnavailable
    case other(Error)
    
    var description: String {
        switch self {
        case .notSignedIn: return String(localized: "icloud_error_not_signed_in")
        case .iCloudDriveUnavailable: return String(localized: "icloud_error_drive_unavailable")
        case .cloudKitUnavailable: return String(localized: "icloud_error_cloudkit_unavailable")
        case .restricted: return String(localized: "icloud_error_restricted")
        case .couldNotDetermine: return String(localized: "icloud_error_could_not_determine")
        case .ubiquityContainerUnavailable: return String(localized: "icloud_error_ubiquity_container_unavailable")
        case .other(let error): return String(format: String(localized: "icloud_error_other"), error.localizedDescription)
        }
    }
}

struct ICloudStatusResult {
    let isSignedInToiCloud: Bool
    let isICloudDriveAvailable: Bool
    let isCloudKitAvailable: Bool
    let errors: [ICloudStatusError]
    
    var isFullyAvailable: Bool {
        return isSignedInToiCloud && isICloudDriveAvailable && isCloudKitAvailable && errors.isEmpty
    }
    
    var errorsMessage: String? {
        return errors.isEmpty ? nil : errors.map { "• \($0.description)" }.joined(separator: "\n")
    }
}

final class ICloudStatusChecker {
    static func checkStatus() async -> ICloudStatusResult {
        var errors: [ICloudStatusError] = []

        // Check if user is signed in to iCloud
        let isSignedIn = FileManager.default.ubiquityIdentityToken != nil
        if !isSignedIn {
            errors.append(.notSignedIn)
        }

        // Check iCloud Drive access
        let hasUbiquity = FileManager.default.url(forUbiquityContainerIdentifier: nil) != nil
        if !hasUbiquity {
            errors.append(.iCloudDriveUnavailable)
        }

        // Check CloudKit account status
        var isCloudKitOK = false
        do {
            let status = try await CKContainer.default().accountStatus()
            switch status {
            case .available:
                isCloudKitOK = true
            case .noAccount:
                isCloudKitOK = false
                errors.append(.notSignedIn)
            case .restricted:
                isCloudKitOK = false
                errors.append(.restricted)
            case .couldNotDetermine:
                isCloudKitOK = false
                errors.append(.couldNotDetermine)
            default:
                isCloudKitOK = false
                errors.append(.couldNotDetermine)
            }
        } catch {
            errors.append(.other(error))
        }

        return ICloudStatusResult(
            isSignedInToiCloud: isSignedIn,
            isICloudDriveAvailable: hasUbiquity,
            isCloudKitAvailable: isCloudKitOK,
            errors: errors
        )
    }
}
