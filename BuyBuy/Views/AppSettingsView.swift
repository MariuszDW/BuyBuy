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
            Section(header: Text("unit_systems")) {
                Toggle(MeasureUnitSystem.metric.name, isOn: $viewModel.isMetricUnitsEnabled)
                    .onChange(of: viewModel.isMetricUnitsEnabled) { newValue in
                        viewModel.setMetricUnitsEnabled(newValue)
                    }
                
                Toggle(MeasureUnitSystem.imperial.name, isOn: $viewModel.isImperialUnitsEnabled)
                    .onChange(of: viewModel.isImperialUnitsEnabled) { newValue in
                        viewModel.setImperialUnitsEnabled(newValue)
                    }
            }
            
#if DEBUG
            Section(header: Text("debug")) {
                Button("copy_mocks_to_database") {
                    showCopyMocksConfirmation = true
                }
            }
#endif
        }
        .navigationTitle("settings")
        .navigationBarTitleDisplayMode(.large)
#if DEBUG
        .alert("copy_mocks_to_database", isPresented: $showCopyMocksConfirmation) {
            Button("cancel", role: .cancel) {}
            Button("ok") {
                Task {
                    await viewModel.copyMockToData()
                }
            }
        } message: {
            Text("are_you_sure")
        }
#endif
    }
}

// MARK: - Preview

#Preview("Light") {
    let dataManager = DataManager(repository: MockDataRepository(lists: []),
                                  imageStorage: MockImageStorage())
    let coordinator = AppCoordinator(dependencies: AppDependencies())
    NavigationStack {
        AppSettingsView(viewModel: AppSettingsViewModel(dataManager: dataManager,
                                                        preferences: AppPreferences(),
                                                        coordinator: coordinator))
    }
    .preferredColorScheme(.light)
}

#Preview("Dark") {
    let dataManager = DataManager(repository: MockDataRepository(lists: []),
                                  imageStorage: MockImageStorage())
    let coordinator = AppCoordinator(dependencies: AppDependencies())
    NavigationStack {
        AppSettingsView(viewModel: AppSettingsViewModel(dataManager: dataManager,
                                                        preferences: AppPreferences(),
                                                        coordinator: coordinator))
    }
    .preferredColorScheme(.dark)
}
