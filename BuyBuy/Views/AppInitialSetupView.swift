//
//  AppInitialSetupView.swift
//  BuyBuy
//
//  Created by MDW on 05/07/2025.
//

import SwiftUI

struct AppInitialSetupView: View {
    @StateObject var viewModel: AppInitialSetupViewModel
    @Environment(\.dismiss) private var dismiss

    init(viewModel: AppInitialSetupViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ZStack {
            NavigationStack {
                List {
                    Section {
                        Text("initial_choice_note")
                            .font(.semiboldDynamic(style: .footnote))
                            .foregroundColor(.bb.text.tertiary)
                            .multilineTextAlignment(.leading)
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.bb.background2.opacity(0.4))
                    }
                    
                    Section {
                        dataStorageView
                            .listRowSeparator(.hidden)
                    } header: {
                        sectionHeader("data_storage")
                    }
                    
                    Section {
                        unitSystemsView
                            .listRowSeparator(.hidden)
                    } header: {
                        sectionHeader("unit_systems")
                    }
                }
                .listStyle(.plain)
                .navigationTitle("initial_settings")
                .navigationBarTitleDisplayMode(.inline)
                .disabled(viewModel.showProgressIndicator)
                .blur(radius: viewModel.showProgressIndicator ? 3 : 0)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("ok") {
                            Task {
                                viewModel.verifyInitSetup()
                            }
                        }
                        .disabled(viewModel.showProgressIndicator)
                    }
                }
                .onChange(of: viewModel.canDismiss) { canDismiss in
                    if canDismiss {
                        dismiss()
                    }
                }
            }

            if viewModel.showProgressIndicator {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()

                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .controlSize(.large)
                    .padding(8)
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)
            }
        }
        .alert("icloud_unavailable", isPresented: Binding<Bool>(
            get: { viewModel.iCloudErrorMessage != nil },
            set: { newValue in
                if !newValue {
                    viewModel.iCloudErrorMessage = nil
                }
            }
        )) {
            Button("ok", role: .destructive) {
                viewModel.iCloudErrorMessage = nil
            }
        } message: {
            Text(viewModel.iCloudErrorMessage ?? "")
        }
    }
    
    @ViewBuilder
    private var dataStorageView: some View {
        HStack(alignment: .center, spacing: 16) {
            storageOptionView(
                imageName: "internaldrive",
                title: "device",
                description: "device_storage_info",
                isSelected: !viewModel.isCloudSelected
            ) {
                viewModel.isCloudSelected = false
            }
            
            storageOptionView(
                imageName: "icloud",
                title: "icloud",
                description: "icloud_storage_info",
                isSelected: viewModel.isCloudSelected
            ) {
                viewModel.isCloudSelected = true
            }
        }
        .padding(.horizontal)
        .frame(maxWidth: 800)
        .fixedSize(horizontal: false, vertical: true)
    }
    
    @ViewBuilder
    private var unitSystemsView: some View {
        HStack(spacing: 16) {
            Spacer()
            
            HStack {
                Image(systemName: viewModel.metricSystem ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(viewModel.metricSystem ? Color.bb.accent : Color.bb.text.secondary)
                Text("unit_system_metric")
                    .font(.semiboldDynamic(style: .headline))
                    .foregroundColor(.bb.text.primary)
            }
            .onTapGesture {
                viewModel.metricSystem.toggle()
            }
            
            Spacer()
            
            HStack {
                Image(systemName: viewModel.imperialSystem ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(viewModel.imperialSystem ? Color.bb.accent : Color.bb.text.secondary)
                Text("unit_system_imperial")
                    .font(.semiboldDynamic(style: .headline))
                    .foregroundColor(.bb.text.primary)
            }
            .onTapGesture {
                viewModel.imperialSystem.toggle()
            }
            
            Spacer()
        }
    }
    
    @ViewBuilder
    private func storageOptionView(
        imageName: String,
        title: LocalizedStringKey,
        description: LocalizedStringKey,
        isSelected: Bool,
        action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Image(systemName: imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundStyle(isSelected ? Color.bb.accent : Color.bb.text.quaternary)
                
                HStack {
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(isSelected ? Color.bb.accent : Color.bb.text.secondary)
                    Text(title)
                        .font(.semiboldDynamic(style: .headline))
                        .foregroundColor(.bb.text.primary)
                }
                
                Text(description)
                    .font(.regularDynamic(style: .footnote))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.bb.text.secondary)
                    .padding(.horizontal, 4)
                
                Spacer(minLength: 0)
            }
            .padding(8)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.bb.accent : Color.bb.text.quaternary, lineWidth: 3)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
    
    @ViewBuilder
    private func sectionHeader(_ text: LocalizedStringKey) -> some View {
        HStack {
            Spacer()
            Text(text)
                .font(.boldDynamic(style: .title3))
                .foregroundStyle(Color.bb.text.secondary)
            Spacer()
        }
    }
}

// MARK: - Preview

#Preview("Light") {
    let preferences = MockAppPreferences()
    let coordinator = AppCoordinator(preferences: preferences)
    let viewModel = AppInitialSetupViewModel(preferences: preferences,
                                             coordinator: coordinator)
    
    AppInitialSetupView(viewModel: viewModel)
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    let preferences = MockAppPreferences()
    let coordinator = AppCoordinator(preferences: preferences)
    let viewModel = AppInitialSetupViewModel(preferences: preferences,
                                             coordinator: coordinator)
    
    AppInitialSetupView(viewModel: viewModel)
        .preferredColorScheme(.dark)
}
