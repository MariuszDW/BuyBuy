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
    private var preferences: AppPreferencesProtocol
    var dynamicTypeSize: DynamicTypeSize = .large
    var colorScheme: ColorScheme = .light
    
    init(preferences: AppPreferencesProtocol, coordinator: any AppCoordinatorProtocol) {
        self.preferences = preferences
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
        let body = reportCreator.buildIssueReportBody(
            preferences: preferences,
            dynamicTypeSize: dynamicTypeSize,
            colorScheme: colorScheme)
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
    
    func titleAndVersion() -> String {
        var titleString: String = Bundle.main.appName() + " " + Bundle.main.appVersion()
        if let releaseDate = Bundle.main.appReleaseDate() {
            titleString += " (\(releaseDate.localizedString()))"
        }
        return titleString
    }
}
