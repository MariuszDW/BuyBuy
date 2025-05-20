//
//  SettingsView.swift
//  BuyBuy
//
//  Created by MDW on 16/05/2025.
//

import SwiftUI

struct SettingsView: View {
    @StateObject var viewModel: SettingsViewModel
    
    init(viewModel: SettingsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        List {
            Text("Settings Placeholder")
            Button("Close") {
                viewModel.close()
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        SettingsView(viewModel: SettingsViewModel(coordinator: AppCoordinator(dependencies: AppDependencies())))
    }
}
