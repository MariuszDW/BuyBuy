//
//  AppSettingsView.swift
//  BuyBuy
//
//  Created by MDW on 16/05/2025.
//

import SwiftUI

struct AppSettingsView: View {
    @StateObject var viewModel: AppSettingsViewModel
    
    @State private var iCloudSyncState: Bool
    
#if DEBUG
    @State private var showCopyMocksConfirmation = false
#endif
    
    init(viewModel: AppSettingsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
        iCloudSyncState = viewModel.isCloudSyncEnabled
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
            
            Section(header: Text("data_storage")) {
                Toggle("icloud_sync", isOn: $iCloudSyncState)
                    .onChange(of: iCloudSyncState) { newValue in
                        viewModel.changeCloudSyncState(newValue)
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
                                  imageStorage: MockImageStorage(),
                                  fileStorage: MockFileStorage())
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
                                  imageStorage: MockImageStorage(),
                                  fileStorage: MockFileStorage())
    let coordinator = AppCoordinator(dependencies: AppDependencies())
    NavigationStack {
        AppSettingsView(viewModel: AppSettingsViewModel(dataManager: dataManager,
                                                        preferences: AppPreferences(),
                                                        coordinator: coordinator))
    }
    .preferredColorScheme(.dark)
}
