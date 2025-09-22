//
//  CKShare+Extenstions.swift
//  BuyBuy
//
//  Created by MDW on 11/09/2025.
//

import Foundation
import CloudKit

private extension CKShare.ParticipantRole {
    var debugDescriptionString: String {
        switch self {
        case .owner: return "Owner"
        case .privateUser: return "Private User"
        case .publicUser: return "Public User"
        default: return "Unknown Role"
        }
    }
}

private extension CKShare.ParticipantPermission {
    var debugDescriptionString: String {
        switch self {
        case .unknown: return "Unknown"
        case .none: return "None"
        case .readOnly: return "Read Only"
        case .readWrite: return "Read & Write"
        default: return "Unknown Permission"
        }
    }
}

private extension CKShare.ParticipantAcceptanceStatus {
    var debugDescriptionString: String {
        switch self {
        case .unknown: return "Unknown"
        case .pending: return "Pending"
        case .accepted: return "Accepted"
        case .removed: return "Removed"
        default: return "Unknown Status"
        }
    }
}

extension CKUserIdentity {
    var debugDescriptionString: String {
        var parts: [String] = []

        if let name = nameComponents?.formatted() {
            parts.append("Name: \(name)")
        }

        if let email = lookupInfo?.emailAddress {
            parts.append("Email: \(email)")
        }

        if let phone = lookupInfo?.phoneNumber {
            parts.append("Phone: \(phone)")
        }

        if let recordID = userRecordID?.recordName {
            parts.append("UserRecordID: \(recordID)")
        }

        parts.append("Has iCloud: \(hasiCloudAccount)")

        return parts.joined(separator: ", ")
    }
}

extension CKShare {
    var isOwnedByMe: Bool {
        return owner.userIdentity.userRecordID?.recordName == CKCurrentUserDefaultName
    }
    
    var participantInfos: [SharingParticipantInfo] {
        participants.map(SharingParticipantInfo.init(from:))
    }
    
    func detailedDescription() -> String {
        var lines: [String] = []
        lines.append("CKShare {")
        lines.append("  recordName: \(recordID.recordName)")
        lines.append("  owner: \(owner.userIdentity.debugDescriptionString)")
        lines.append("  publicPermission: \(publicPermission)")
        lines.append("  participants:")

        for participant in participants {
            lines.append("  - identity: \(participant.userIdentity.debugDescriptionString)")
            lines.append("    role: \(participant.role.debugDescriptionString)")
            lines.append("    permission: \(participant.permission.debugDescriptionString)")
            lines.append("    acceptance: \(participant.acceptanceStatus.debugDescriptionString)")
        }

        lines.append("}")
        return lines.joined(separator: "\n")
    }
}
