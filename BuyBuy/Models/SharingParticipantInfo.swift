//
//  SharingParticipantInfo.swift
//  BuyBuy
//
//  Created by MDW on 07/09/2025.
//

import Foundation
import CloudKit

struct SharingParticipantInfo: Hashable, Equatable {
    let displayName: String
    let role: CKShare.ParticipantRole
    let acceptanceStatus: CKShare.ParticipantAcceptanceStatus
    let permission: CKShare.ParticipantPermission
    let userRecordID: CKRecord.ID?
    
    init(displayName: String,
         role: CKShare.ParticipantRole,
         acceptanceStatus: CKShare.ParticipantAcceptanceStatus,
         permission: CKShare.ParticipantPermission,
         userRecordID: CKRecord.ID?) {
        self.displayName = displayName
        self.role = role
        self.acceptanceStatus = acceptanceStatus
        self.permission = permission
        self.userRecordID = userRecordID
    }
    
    init(from participant: CKShare.Participant) {
        let userIdentity = participant.userIdentity
        
        if let recordID = userIdentity.userRecordID,
           recordID.recordName == CKCurrentUserDefaultName {
            self.displayName = String(localized: "participant_you")
        } else {
            self.displayName =
            userIdentity.nameComponents?.formatted()
            ?? userIdentity.lookupInfo?.emailAddress
            ?? userIdentity.lookupInfo?.phoneNumber
            ?? userIdentity.lookupInfo?.userRecordID?.recordName
            ?? String(localized: "participant_unknown")
        }
        
        self.role = participant.role
        self.acceptanceStatus = participant.acceptanceStatus
        self.permission = participant.permission
        self.userRecordID = userIdentity.userRecordID
    }
}
