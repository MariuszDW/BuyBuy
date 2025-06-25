//
//  AppSettingsView.swift
//  BuyBuy
//
//  Created by MDW on 16/05/2025.
//

import SwiftUI

enum DataStorageOption: String, CaseIterable, Identifiable {
    case device
    case cloud

    var id: String { rawValue }

    var iconName: String {
        switch self {
        case .device: return "icloud.slash"
        case .cloud: return "icloud"
        }
    }
    
    var title: String {
        switch self {
        case .device: String(localized: "device")
        case .cloud: String(localized: "icloud")
        }
    }
}

struct AppSettingsView: View {
    @StateObject var viewModel: AppSettingsViewModel
    
#if DEBUG
    @State private var showCopyMocksConfirmation = false
#endif
    
    init(viewModel: AppSettingsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        ZStack {
            Form {
                Section(header: Text("data_storage"),
                        footer: Text(viewModel.isCloudSyncEnabled ? "icloud_storage_info" : "device_storage_info")) {
                    dataStorageView
                }
                
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
            .disabled(viewModel.progressIndicator)
            .blur(radius: viewModel.progressIndicator ? 3 : 0)
            
            if viewModel.progressIndicator {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .controlSize(.large)
                    .frame(maxWidth: .infinity)
                    .padding(8)
            }
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
    
    private var dataStorageView: some View {
        HStack {
            Text("storage")
            Spacer()
            Menu {
                ForEach(DataStorageOption.allCases) { option in
                    Button {
                        viewModel.setCloudStorage(enabled: option == .cloud)
                    } label: {
                        Label(option.title, systemImage: option.iconName)
                    }
                }
            } label: {
                HStack(spacing: 8) {
                    Text(viewModel.isCloudSyncEnabled ? DataStorageOption.cloud.title : DataStorageOption.device.title)
                    Image(systemName: "chevron.up.chevron.down")
                        .padding(.leading, 4)
                }
            }
        }
    }
}

// MARK: - Preview

#Preview("Light") {
    let dataManager = DataManager(useCloud: false,
                                  coreDataStack: MockCoreDataStack(),
                                  imageStorage: MockImageStorage(),
                                  fileStorage: MockFileStorage(),
                                  repository: MockDataRepository(lists: []))
    let preferences = MockAppPreferences()
    let coordinator = AppCoordinator(preferences: preferences)
    NavigationStack {
        AppSettingsView(viewModel: AppSettingsViewModel(dataManager: dataManager,
                                                        preferences: preferences,
                                                        coordinator: coordinator))
    }
    .preferredColorScheme(.light)
}

#Preview("Dark") {
    let dataManager = DataManager(useCloud: false,
                                  coreDataStack: MockCoreDataStack(),
                                  imageStorage: MockImageStorage(),
                                  fileStorage: MockFileStorage(),
                                  repository: MockDataRepository(lists: []))
    let preferences = MockAppPreferences()
    let coordinator = AppCoordinator(preferences: preferences)
    NavigationStack {
        AppSettingsView(viewModel: AppSettingsViewModel(dataManager: dataManager,
                                                        preferences: preferences,
                                                        coordinator: coordinator))
    }
    .preferredColorScheme(.dark)
}
