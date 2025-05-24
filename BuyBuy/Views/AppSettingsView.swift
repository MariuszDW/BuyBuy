//
//  AppSettingsView.swift
//  BuyBuy
//
//  Created by MDW on 16/05/2025.
//

import SwiftUI

struct AppSettingsView: View {
    @StateObject var viewModel: AppSettingsViewModel
    
#if DEBUG
    @State private var showCopyMocksConfirmation = false
#endif
    
    init(viewModel: AppSettingsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        Form {
            Section {
                Text("Application Settings Placeholder")
            }
            
#if DEBUG
            Section(header: Text("DEBUG")) {
                Button("Copy mocks to database") {
                    showCopyMocksConfirmation = true
                }
            }
#endif
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.large)
#if DEBUG
        .alert("Copy mocks to DataBase?", isPresented: $showCopyMocksConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Copy") {
                Task {
                    await viewModel.copyMockToRepository()
                }
            }
        }
#endif
    }
}

// MARK: - Preview

#Preview("Light") {
    let repository = MockShoppingListsRepository()
    let coordinator = AppCoordinator(dependencies: AppDependencies())
    
    NavigationStack {
        AppSettingsView(viewModel: AppSettingsViewModel(repository: repository, coordinator: coordinator))
    }
    .preferredColorScheme(.light)
}

#Preview("Dark") {
    let repository = MockShoppingListsRepository()
    let coordinator = AppCoordinator(dependencies: AppDependencies())
    
    NavigationStack {
        AppSettingsView(viewModel: AppSettingsViewModel(repository: repository, coordinator: coordinator))
    }
    .preferredColorScheme(.dark)
}
