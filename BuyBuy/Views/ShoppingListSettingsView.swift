//
//  ShoppingListSettingsView.swift
//  BuyBuy
//
//  Created by MDW on 17/05/2025.
//

import SwiftUI

enum ShoppingListSettingsField: Hashable {
    case name
}

struct ShoppingListSettingsView: View {
    @StateObject var viewModel: ShoppingListSettingsViewModel
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focusedField: ShoppingItemDetailsField?
    
    init(viewModel: ShoppingListSettingsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    nameField
                    iconAndColorSection
                    iconsGridSection
                }
                .padding()
            }
            .navigationTitle("shopping_list")
            .navigationBarTitleDisplayMode(.inline)
            .safeAreaInset(edge: .bottom) {
                if focusedField != nil {
                    keyboardDismissButton
                }
            }
            .task {
                focusedField = viewModel.isNew ? .name : nil
            }
            .onChange(of: focusedField) { newValue in
                Task {
                    viewModel.finalizeInput()
                }
            }
            .toolbar {
                toolbarContent
            }
            .onAppear {
                viewModel.startObserving()
            }
            .onDisappear {
                viewModel.stopObserving()
                Task { await viewModel.didFinishEditing() }
            }
        }
    }
    
    private var toolbarContent: some ToolbarContent {
        Group {
            if viewModel.isNew {
                ToolbarItem(placement: .cancellationAction) {
                    Button("cancel") {
                        Task {
                            viewModel.changesConfirmed = false
                            dismiss()
                        }
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("ok") {
                        Task {
                            viewModel.changesConfirmed = true
                            dismiss()
                        }
                    }
                    .disabled(!viewModel.canConfirm)
                }
            } else {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        Task {
                            viewModel.changesConfirmed = true
                            dismiss()
                        }
                    } label: {
                        Image(systemName: "xmark.circle")
                            // .accessibilityLabel("Close")
                    }
                    .disabled(!viewModel.canConfirm)
                }
            }
        }
    }
    
    private var keyboardDismissButton: some View {
        HStack {
            Spacer()
            Button {
                focusedField = nil
            } label: {
                Image(systemName: "keyboard.chevron.compact.down")
                    .font(.regularDynamic(style: .title2))
                    .foregroundColor(.bb.selection)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.bb.background.opacity(0.5))
                    )
            }
        }
    }
    
    private var nameField: some View {
        VStack(alignment: .leading, spacing: 8) {
            TextField(
                "list_name",
                text: $viewModel.shoppingList.name
            )
            // .textInputAutocapitalization(.sentences) // TODO: To dodac jako opcje w ustawieniach aplikacji.
            .font(.boldDynamic(style: .title3))
            .focused($focusedField, equals: .name)
            .onSubmit {
                focusedField = nil
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
                    Image(systemName: viewModel.shoppingList.icon.rawValue)
                        .resizable()
                        .scaledToFit()
                        .frame(width: iconSize, height: iconSize)
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.white, viewModel.shoppingList.color.color)
                        .shadow(color: .black.opacity(0.3), radius: 8)
                        .transition(.scale.combined(with: .opacity))
                        .id(viewModel.shoppingList.icon.rawValue)
                        .animation(.easeInOut(duration: 0.25), value: viewModel.shoppingList.color)
                }
                .animation(.spring(response: 0.4, dampingFraction: 0.6), value: viewModel.shoppingList.icon)
                
                LazyVGrid(
                    columns: Array(repeating: GridItem(.flexible()), count: 4),
                    spacing: 4
                ) {
                    ForEach(ListColor.allCases, id: \.self) { color in
                        ZStack {
                            Circle()
                                .stroke(Color.bb.selection, lineWidth: 3)
                                .opacity(viewModel.shoppingList.color == color ? 1 : 0)
                                .frame(width: 44, height: 44)
                            
                            Circle()
                                .fill(color.color)
                                .frame(width: 32, height: 32)
                        }
                        .frame(width: 42, height: 42)
                        .contentShape(Circle())
                        .onTapGesture {
                            focusedField = nil
                            viewModel.shoppingList.color = color
                            Task {
                                viewModel.finalizeInput()
                            }
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
                    if viewModel.shoppingList.icon == icon {
                        Circle()
                            .stroke(Color.bb.selection, lineWidth: 3)
                            .frame(width: 48, height: 48)
                    }
                    
                    icon.image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 36, height: 36)
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.white, viewModel.shoppingList.color.color)
                }
                .frame(width: 48, height: 48)
                .contentShape(Rectangle())
                .onTapGesture {
                    focusedField = nil
                    viewModel.shoppingList.icon = icon
                    Task {
                        viewModel.finalizeInput()
                    }
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

// MARK: - Preview

#Preview("Light") {
    let dataManager = DataManager(repository: MockDataRepository(lists: []),
                                  imageStorage: MockImageStorage(),
                                  fileStorage: MockFileStorage())
    let viewModel = ShoppingListSettingsViewModel(
        list: MockDataRepository.list1,
        dataManager: dataManager,
        coordinator: AppCoordinator(dependencies: AppDependencies()))
    
    ShoppingListSettingsView(viewModel: viewModel)
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    let dataManager = DataManager(repository: MockDataRepository(lists: []),
                                  imageStorage: MockImageStorage(),
                                  fileStorage: MockFileStorage())
    let viewModel = ShoppingListSettingsViewModel(
        list: MockDataRepository.list1,
        dataManager: dataManager,
        coordinator: AppCoordinator(dependencies: AppDependencies()))
    
    ShoppingListSettingsView(viewModel: viewModel)
        .preferredColorScheme(.dark)
}
