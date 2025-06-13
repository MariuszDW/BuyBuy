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
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle")
                        .accessibilityLabel("Close")
                }
            }
        }
    }
    
    func infoContext(isPortrait: Bool) -> some View {
        VStack() {
            Text(Bundle.main.appVersion(prefix: "version ", date: true))
                .font(.regularMonospaced(style: .headline))
                .foregroundColor(.bb.text.primary)
            Text("programming, & design")
                .padding(.top, 16)
                .font(.regularDynamic(style: .body))
            Text("Mariusz Włodarczyk")
                .font(.boldDynamic(style: .title3))
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
