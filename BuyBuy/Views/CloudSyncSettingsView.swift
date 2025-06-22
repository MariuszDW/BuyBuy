//
//  CloudSyncSettingsView.swift
//  BuyBuy
//
//  Created by MDW on 22/06/2025.
//

import SwiftUI

struct CloudSyncSettingsView: View {
    @StateObject var viewModel: CloudSyncSettingsViewModel
    
    init(viewModel: CloudSyncSettingsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        Spacer()
        VStack {
            if viewModel.isCloudSyncEnabled {
                Button("disable_cloud_sync") {
                    viewModel.disableCloudSynd()
                }
            } else {
                Button("enable_cloud_sync") {
                    viewModel.enableCloudSync()
                }
            }
        }
        .navigationTitle("icloud_sync")
        Spacer()
    }
}

// MARK: - Preview

#Preview("Light") {
    let dataManager = DataManager(repository: MockDataRepository(),
                                  imageStorage: MockImageStorage(),
                                  fileStorage: MockFileStorage())
    let preferences = MockAppPreferences()
    let mockViewModel = CloudSyncSettingsViewModel(
        dataManager: dataManager,
        preferences: preferences,
        coordinator: AppCoordinator(dependencies: AppDependencies())
    )
    
    NavigationStack {
        CloudSyncSettingsView(viewModel: mockViewModel)
    }
    .preferredColorScheme(.light)
}

#Preview("Dark") {
    let dataManager = DataManager(repository: MockDataRepository(),
                                  imageStorage: MockImageStorage(),
                                  fileStorage: MockFileStorage())
    let preferences = MockAppPreferences()
    let mockViewModel = CloudSyncSettingsViewModel(
        dataManager: dataManager,
        preferences: preferences,
        coordinator: AppCoordinator(dependencies: AppDependencies())
    )
    
    NavigationStack {
        CloudSyncSettingsView(viewModel: mockViewModel)
    }
    .preferredColorScheme(.dark)
}
