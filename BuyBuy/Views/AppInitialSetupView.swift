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
            mainView
                .disabled(viewModel.showProgressIndicator)
                .blur(radius: viewModel.showProgressIndicator ? 3 : 0)
                .disabled(viewModel.showProgressIndicator)
            
            if viewModel.showProgressIndicator {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .controlSize(.large)
                    .frame(maxWidth: .infinity)
                    .padding(8)
            }
        }
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
        .alert("icloud_unavailable", isPresented: Binding<Bool>(
            get: { viewModel.iCloudErrorMessage != nil },
            set: { newValue in
                if !newValue {
                    viewModel.iCloudErrorMessage = nil
                }
            }
        )) {
            Button("ok", role: .cancel) {
                viewModel.iCloudErrorMessage = nil
            }
        } message: {
            Text(viewModel.iCloudErrorMessage ?? "")
        }
    }
    
    @ViewBuilder
    private var mainView: some View {
        VStack(alignment: .center, spacing: 32) {
            Text("data_storage")
                .font(.boldDynamic(style: .title))
                .padding(.top)
            
            Text("initial_choice_note")
                        .font(.regularDynamic(style: .subheadline))
                        .foregroundColor(.bb.text.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
            
            HStack(spacing: 12) {
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
