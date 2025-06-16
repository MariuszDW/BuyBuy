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
    
    init(viewModel: AboutViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
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
                .font(.regularMonospaced(style: .subheadline))
                .foregroundColor(.bb.text.primary)
                .multilineTextAlignment(.center)
            
            // ---- credits ----
            Text("credits_role")
                .padding(.top, 16)
                .font(.regularDynamic(style: .callout))
                .multilineTextAlignment(.center)
            Text("credits_name")
                .multilineTextAlignment(.center)
                .font(.boldDynamic(style: .title3))
            
            // ---- contact ----
            Text("contact")
                .padding(.top, 16)
                .font(.regularDynamic(style: .callout))
                .multilineTextAlignment(.center)
            
            Button {
                if !viewModel.contactSupport() {
                    showEmailAlert = true
                }
            } label: {
                Text(AppConstants.encoreContactEMail)
                    .font(.boldDynamic(style: .body))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.blue)
                    .allowsHitTesting(false)
            }
            
            // ---- bluesky ----
            Text(AppConstants.blueSkyName)
                .padding(.top, 16)
                .multilineTextAlignment(.center)
                .font(.regularDynamic(style: .callout))
            
            Button {
                _ = viewModel.openBlueSkyWebPage()
            } label: {
                Text(AppConstants.blueSkyAddress)
                    .font(.boldDynamic(style: .body))
                    .multilineTextAlignment(.center)
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
                    .multilineTextAlignment(.center)
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
