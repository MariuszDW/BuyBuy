//
//  AboutView.swift
//  BuyBuy
//
//  Created by MDW on 17/05/2025.
//

import SwiftUI

struct AboutView: View {
    @StateObject var viewModel: AboutViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showEmailAlert = false
    
    var body: some View {
        GeometryReader { geometry in
            if geometry.size.height > geometry.size.width {
                let logoMaxWidth = min(geometry.size.width, geometry.size.height * 0.45)
                ScrollView {
                    VStack(alignment: .center, spacing: 32) {
                        AnimatedAppLogoView()
                            .frame(maxWidth: logoMaxWidth)
                        infoContext(isPortrait: true)
                            .frame(maxWidth: .infinity)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                let logoMaxWidth = min(geometry.size.width * 0.45, geometry.size.height)
                HStack(alignment: .center, spacing: 32) {
                    AnimatedAppLogoView()
                        .frame(maxWidth: logoMaxWidth)
                    ScrollView {
                        infoContext(isPortrait: true)
                            .frame(maxWidth: .infinity)
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationTitle("about")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle")
                        // .accessibilityLabel("Close")
                }
            }
        }
        .alert("email_alert_title", isPresented: $showEmailAlert) {
            Button("ok", role: .cancel) { }
        } message: {
            Text("email_alert_message")
        }
    }
    
    func infoContext(isPortrait: Bool) -> some View {
        VStack() {
            Text(Bundle.main.appVersion(prefix: String(localized: "version") + " ", date: true))
                .font(.regularMonospaced(style: .headline))
                .foregroundColor(.bb.text.primary)
            
            // ---- credits ----
            Text("credits_role")
                .padding(.top, 16)
                .font(.regularDynamic(style: .callout))
            Text("credits_name")
                .font(.boldDynamic(style: .title3))
            
            // ---- contact ----
            Text("e-mail")
                .padding(.top, 16)
                .font(.regularDynamic(style: .callout))
            
            Button {
                if !viewModel.contactSupport() {
                    showEmailAlert = true
                }
            } label: {
                Text("encore_contact@icloud.com")
                    .font(.boldDynamic(style: .body))
                    .foregroundColor(.blue)
                    .allowsHitTesting(false)
            }
            
            // ---- bluesky ----
            Text("Bluesky")
                .padding(.top, 16)
                .font(.regularDynamic(style: .callout))
            
            Button {
                _ = viewModel.openBlueSkyWebPage()
            } label: {
                Text("https://encore-games.bsky.social")
                    .font(.boldDynamic(style: .body))
                    .foregroundColor(.blue)
                    .allowsHitTesting(false)
            }
            
            // ---- report issue ----
            Button {
                if !viewModel.reportIssue() {
                    showEmailAlert = true
                }
            } label: {
                Text("report_issue")
                    .font(.boldDynamic(style: .body))
                    .foregroundColor(.blue)
            }
            .padding(.top, 16)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, isPortrait ? 16 : 4)
    }
}

// MARK: - Preview

#Preview("Light") {
    NavigationStack {
        let coordinator = AppCoordinator(dependencies: AppDependencies())
        let viewModel = AboutViewModel(coordinator: coordinator)
        AboutView(viewModel: viewModel)
    }
    .preferredColorScheme(.light)
}

#Preview("Dark") {
    NavigationStack {
        let coordinator = AppCoordinator(dependencies: AppDependencies())
        let viewModel = AboutViewModel(coordinator: coordinator)
        AboutView(viewModel: viewModel)
    }
    .preferredColorScheme(.dark)
}
