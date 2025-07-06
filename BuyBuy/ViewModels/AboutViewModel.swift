//
//  AboutViewModel.swift
//  BuyBuy
//
//  Created by MDW on 12/06/2025.
//

import SwiftUI

@MainActor
final class AboutViewModel: ObservableObject {
    private weak var coordinator: (any AppCoordinatorProtocol)?
    
    init(coordinator: any AppCoordinatorProtocol) {
        self.coordinator = coordinator
    }
    
    func contactSupport() -> Bool {
        return coordinator?.openEmail(
            to: AppConstants.encoreContactEMail,
            subject: String(localized: "contact_subject"),
            body: ""
        ) ?? false
    }
    
    func reportIssue() -> Bool {
        let reportCreator = ReportCreator()
        let body = reportCreator.buildIssueReportBody()
        return coordinator?.openEmail(
            to: AppConstants.encoreContactEMail,
            subject: String(localized: "issue_report_subject"),
            body: body
        ) ?? false
    }
    
    func openBlueSkyWebPage() -> Bool {
        return coordinator?.openWebPage(address: "https://encore-games.bsky.social") ?? false
    }
    
    func openTipJar() {
        coordinator?.openTipJar(onDismiss: { _ in })
    }
}
