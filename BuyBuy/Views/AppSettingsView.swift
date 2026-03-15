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
        case .device: return "internaldrive"
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

enum AppSettingsField {
    case defaultUnit
}

struct AppSettingsView: View {
    @StateObject var viewModel: AppSettingsViewModel
    
    @FocusState private var focusedField: AppSettingsField?
    
#if BUYBUY_DEV
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
                            focusedField = nil
                            viewModel.setMetricUnitsEnabled(newValue)
                        }
                    
                    Toggle(MeasureUnitSystem.imperial.name, isOn: $viewModel.isImperialUnitsEnabled)
                        .onChange(of: viewModel.isImperialUnitsEnabled) { newValue in
                            focusedField = nil
                            viewModel.setImperialUnitsEnabled(newValue)
                        }
                    
                    HStack {
                        Text("default_unit")
                        
                        Spacer()
                        
                        TextField(
                            String(localized: .none),
                            text: Binding(
                                get: { viewModel.defaultUnit ?? "" },
                                set: { viewModel.setDefaultUnit($0) }
                            )
                        )
                        .focused($focusedField, equals: .defaultUnit)
                        .multilineTextAlignment(.trailing)
                        .textFieldStyle(.roundedBorder)
                        .frame(maxWidth: 120)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        
                        Menu {
                            ForEach(viewModel.unitList, id: \.name) { section in
                                Section(section.name) {
                                    ForEach(section.units, id: \.self) { unit in
                                        Button {
                                            focusedField = nil
                                            viewModel.setDefaultUnit(unit.symbol)
                                        } label: {
                                            Text(unit.symbol + " – " + unit.name)
                                        }
                                    }
                                }
                            }
                        } label: {
                            Image(systemName: "chevron.up.chevron.down")
                                .foregroundColor(.bb.selection)
                        }
                    }
                }
                
                Section {
                    Toggle(isOn: $viewModel.isHapticsEnabled) {
                        Label {
                            Text("haptics")
                        } icon: {
                            Image(systemName: "hand.tap.fill")
                        }
                    }
                    .onChange(of: viewModel.isHapticsEnabled) { newValue in
                        focusedField = nil
                        viewModel.setHapticsEnabled(newValue)
                    }
                }
                
                Section() {
                    Button {
                        focusedField = nil
                        viewModel.openTipJar()
                    } label: {
                        Label("support_developer", systemImage: "cup.and.saucer.fill")
                    }
                }
                
#if BUYBUY_DEV
                Section(header: Text("debug")) {
                    Button("copy_mocks_to_database") {
                        focusedField = nil
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
        .alert("icloud_unavailable", isPresented: Binding<Bool>(
            get: { viewModel.iCloudErrorMessage != nil },
            set: { newValue in
                if !newValue {
                    viewModel.iCloudErrorMessage = nil
                }
            }
        )) {
            Button("ok", role: .cancel) {
                focusedField = nil
                viewModel.iCloudErrorMessage = nil
            }
        } message: {
            Text(viewModel.iCloudErrorMessage ?? "")
        }
#if BUYBUY_DEV
        .alert("copy_mocks_to_database", isPresented: $showCopyMocksConfirmation) {
            Button("cancel", role: .cancel) {}
            Button("ok") {
                Task {
                    focusedField = nil
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
                                  repository: MockDataRepository(lists: []))
    let preferences = MockAppPreferences()
    let mockHapticEngine = MockHapticEngine()
    let coordinator = AppCoordinator(preferences: preferences)
    NavigationStack {
        AppSettingsView(viewModel: AppSettingsViewModel(
            dataManager: dataManager,
            hapticEngine: mockHapticEngine,
            preferences: preferences,
            coordinator: coordinator)
        )
    }
    .preferredColorScheme(.light)
}

#Preview("Dark") {
    let dataManager = DataManager(useCloud: false,
                                  repository: MockDataRepository(lists: []))
    let preferences = MockAppPreferences()
    let mockHapticEngine = MockHapticEngine()
    let coordinator = AppCoordinator(preferences: preferences)
    NavigationStack {
        AppSettingsView(viewModel: AppSettingsViewModel(
            dataManager: dataManager,
            hapticEngine: mockHapticEngine,
            preferences: preferences,
            coordinator: coordinator)
        )
    }
    .preferredColorScheme(.dark)
}
