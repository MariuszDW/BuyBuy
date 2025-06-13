//
//  AboutViewModel.swift
//  BuyBuy
//
//  Created by MDW on 12/06/2025.
//

import SwiftUI

@MainActor
final class AboutViewModel: ObservableObject {
    var coordinator: any AppCoordinatorProtocol
    
    init(coordinator: any AppCoordinatorProtocol) {
        self.coordinator = coordinator
    }
    
    func contactSupport() -> Bool {
        return coordinator.openEmail(
            to: "encore_contact@icloud.com",
            subject: String(localized: "contact_subject"),
            body: ""
        )
    }
    
    func reportIssue() -> Bool {
        let reportCreator = ReportCreator()
        let body = reportCreator.buildIssueReportBody()
        return coordinator.openEmail(
            to: "encore_contact@icloud.com",
            subject: String(localized: "issue_report_subject"),
            body: body
        )
    }
    
    func openBlueSkyWebPage() -> Bool {
        return coordinator.openWebPage(address: "https://encore-games.bsky.social")
    }
}
