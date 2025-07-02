//
//  AboutView.swift
//  BuyBuy
//
//  Created by MDW on 17/05/2025.
//

import SwiftUI

struct AboutView: View {
    @StateObject var viewModel: AboutViewModel
    @State private var showEmailAlert = false
    
    init(viewModel: AboutViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        GeometryReader { geometry in
            if geometry.size.isPortrait {
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
                .gesture(
                    DragGesture(minimumDistance: 4),
                    including: .gesture
                )
            } else {
                let logoMaxWidth = min(geometry.size.width * 0.45, geometry.size.height)
                HStack(alignment: .center, spacing: 32) {
                    AnimatedAppLogoView()
                        .frame(maxWidth: logoMaxWidth)
                    ScrollView {
                        infoContext(isPortrait: true)
                            .frame(maxWidth: .infinity)
                    }
                    .gesture(
                        DragGesture(minimumDistance: 4),
                        including: .gesture
                    )
                }
                .frame(maxWidth: .infinity)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationTitle("about")
        .navigationBarTitleDisplayMode(.inline)
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
                .padding(.bottom, 32)
            
            VStack(spacing: 16) {
                // ---- contact ----
                Button {
                    if !viewModel.contactSupport() {
                        showEmailAlert = true
                    }
                } label: {
                    VStack(spacing: 2) {
                        Label("contact", systemImage: "envelope.fill")
                        Text(AppConstants.encoreContactEMail)
                            .font(.regularDynamic(style: .caption))
                            .opacity(0.85)
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(BBPlainButtonStyle())
                
                // ---- report issue ----
                Button {
                    if !viewModel.reportIssue() {
                        showEmailAlert = true
                    }
                } label: {
                    Label("report_issue", systemImage: "exclamationmark.bubble.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(BBPlainButtonStyle())
                
                // ---- support developer ----
                Button {
                    viewModel.openTipJar()
                } label: {
                    Label("support_developer", systemImage: "cup.and.saucer.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(BBPlainButtonStyle())
                
                // ---- bluesky ----
                Button {
                    _ = viewModel.openBlueSkyWebPage()
                } label: {
                    VStack(spacing: 2) {
                        Label(AppConstants.blueSkyName, systemImage: "globe")
                        Text(AppConstants.blueSkyAddress)
                            .font(.regularDynamic(style: .caption))
                            .opacity(0.85)
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(BBPlainButtonStyle())
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 32)
        }
        .padding(.horizontal, isPortrait ? 16 : 4)
    }
}

// MARK: - Preview

#Preview("Light") {
    NavigationStack {
        let preferences = MockAppPreferences()
        let coordinator = AppCoordinator(preferences: preferences)
        let viewModel = AboutViewModel(coordinator: coordinator)
        AboutView(viewModel: viewModel)
    }
    .preferredColorScheme(.light)
}

#Preview("Dark") {
    NavigationStack {
        let preferences = MockAppPreferences()
        let coordinator = AppCoordinator(preferences: preferences)
        let viewModel = AboutViewModel(coordinator: coordinator)
        AboutView(viewModel: viewModel)
    }
    .preferredColorScheme(.dark)
}
