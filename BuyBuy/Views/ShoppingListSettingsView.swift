//
//  ShoppingListSettingsView.swift
//  BuyBuy
//
//  Created by MDW on 17/05/2025.
//

import SwiftUI

struct ShoppingListSettingsView: View {
    @StateObject var viewModel: ShoppingListSettingsViewModel
    @Environment(\.dismiss) private var dismiss
    
    @FocusState private var focusedNameField: Bool?
    
    init(viewModel: ShoppingListSettingsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    nameSection
                    iconAndColorSection
                    iconsGridSection
                }
                .padding()
            }
            .navigationTitle("List settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("OK") {
                        Task {
                            await viewModel.applyChanges()
                            dismiss()
                        }
                    }
                    .disabled(viewModel.list.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
    
    private var nameSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            TextField(
                "List name",
                text: $viewModel.list.name
            )
            // .textInputAutocapitalization(.sentences) // TODO: To dodac jak opcje w ustawieniach aplikacji.
            .font(.boldDynamic(style: .title3))
            .focused($focusedNameField, equals: true)
            .task {
                focusedNameField = viewModel.isNew
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
    
    private var iconAndColorSection: some View {
        let screenSize = UIScreen.main.bounds.size
        let shortSide = min(screenSize.width, screenSize.height)
        let iconSize = shortSide * 0.32
        
        return VStack {
            HStack(alignment: .top, spacing: 24) {
                ZStack {
                    Image(systemName: viewModel.list.icon.rawValue)
                        .resizable()
                        .scaledToFit()
                        .frame(width: iconSize, height: iconSize)
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.white, viewModel.list.color.color)
                        .shadow(color: .black.opacity(0.3), radius: 8)
                        .transition(.scale.combined(with: .opacity))
                        .id(viewModel.list.icon.rawValue)
                        .animation(.easeInOut(duration: 0.25), value: viewModel.list.color)
                }
                .animation(.spring(response: 0.4, dampingFraction: 0.6), value: viewModel.list.icon)
                
                LazyVGrid(
                    columns: Array(repeating: GridItem(.flexible()), count: 4),
                    spacing: 4
                ) {
                    ForEach(ListColor.allCases, id: \.self) { color in
                        ZStack {
                            Circle()
                                .stroke(Color.bb.selection, lineWidth: 3)
                                .opacity(viewModel.list.color == color ? 1 : 0)
                                .frame(width: 44, height: 44)
                            
                            Circle()
                                .fill(color.color)
                                .frame(width: 32, height: 32)
                        }
                        .frame(width: 42, height: 42)
                        .contentShape(Circle())
                        .onTapGesture {
                            viewModel.list.color = color
                        }
                    }
                }
                .frame(height: iconSize)
                .frame(maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
    
    private var iconsGridSection: some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 5),
            spacing: 16
        ) {
            ForEach(ListIcon.allCases, id: \.self) { icon in
                ZStack {
                    if viewModel.list.icon == icon {
                        Circle()
                            .stroke(Color.bb.selection, lineWidth: 3)
                            .frame(width: 48, height: 48)
                    }
                    
                    Image(systemName: icon.rawValue)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 36, height: 36)
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.white, viewModel.list.color.color)
                }
                .frame(width: 48, height: 48)
                .contentShape(Rectangle())
                .onTapGesture {
                    viewModel.list.icon = icon
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

// MARK: - Preview

#Preview("Light Mode") {
    let repository = MockShoppingListsRepository()
    let viewModel = ShoppingListSettingsViewModel(
        list: MockShoppingListsRepository.list1,
        repository: repository,
        coordinator: AppCoordinator(dependencies: AppDependencies()),
        onSave: {}
    )
    
    ShoppingListSettingsView(viewModel: viewModel)
        .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    let repository = MockShoppingListsRepository()
    let viewModel = ShoppingListSettingsViewModel(
        list: MockShoppingListsRepository.list1,
        repository: repository,
        coordinator: AppCoordinator(dependencies: AppDependencies()),
        onSave: {}
    )
    
    ShoppingListSettingsView(viewModel: viewModel)
        .preferredColorScheme(.dark)
}
