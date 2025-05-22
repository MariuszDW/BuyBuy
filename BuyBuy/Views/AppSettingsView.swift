//
//  AppSettingsView.swift
//  BuyBuy
//
//  Created by MDW on 16/05/2025.
//

import SwiftUI

struct AppSettingsView: View {
    @StateObject var viewModel: AppSettingsViewModel
    
    init(viewModel: AppSettingsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        List {
            Text("Application Settings Placeholder")
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
        AppSettingsView(viewModel: AppSettingsViewModel(coordinator: AppCoordinator(dependencies: AppDependencies())))
    }
}
