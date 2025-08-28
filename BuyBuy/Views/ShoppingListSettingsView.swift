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
    
    private let fieldCornerRadius: CGFloat = 12
    
    init(viewModel: ShoppingListSettingsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        GeometryReader { geometry in
            NavigationStack {
                ScrollView {
                    VStack(spacing: 16) {
                        nameField
                        iconAndColorSection(width: geometry.size.width)
                        iconsGridSection(width: geometry.size.width)
                    }
                    .padding()
                }
                .background(Color.bb.sheet.background)
                .navigationTitle("shopping_list")
                .navigationBarTitleDisplayMode(.inline)
                .safeAreaInset(edge: .bottom) {
                    if focusedField != nil {
                        KeyboardDismissButton {
                            focusedField = nil
                        }
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
                        CircleIconView(systemName: "xmark")
                            // .accessibilityLabel("Close")
                    }
                    .disabled(!viewModel.canConfirm)
                }
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
        .background(Color.bb.sheet.section.background)
        .cornerRadius(fieldCornerRadius)
    }
    
    @ViewBuilder
    private func iconAndColorSection(width: CGFloat) -> some View {
        let iconSize = width * 0.32
        let smallIconSize = width * 0.066
        let smallIconOutlineLineWidth = max(width * 0.006, 4)
        let smallIconOutlineSize = smallIconSize + (smallIconOutlineLineWidth * 3)
        let verticalSpacing = smallIconSize * 0.24
        
        VStack {
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
                    spacing: verticalSpacing
                ) {
                    ForEach(ListColor.allCases, id: \.self) { color in
                        ZStack {
                            Circle()
                                .stroke(Color.bb.selection, lineWidth: smallIconOutlineLineWidth)
                                .opacity(viewModel.shoppingList.color == color ? 1 : 0)
                                .frame(width: smallIconOutlineSize, height: smallIconOutlineSize)
                            
                            Circle()
                                .fill(color.color)
                                .frame(width: smallIconSize, height: smallIconSize)
                        }
                        .frame(minWidth: smallIconOutlineSize, minHeight: smallIconOutlineSize)
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
        .background(Color.bb.sheet.section.background)
        .cornerRadius(fieldCornerRadius)
    }
    
    @ViewBuilder
    private func iconsGridSection(width: CGFloat) -> some View {
        let smallIconSize = width * 0.09
        let smallIconOutlineLineWidth = max(width * 0.006, 4)
        let smallIconOutlineSize = smallIconSize + (smallIconOutlineLineWidth * 3)
        let verticalSpacing = smallIconSize * 0.28
        
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible()), count: 5),
            spacing: verticalSpacing
        ) {
            ForEach(ListIcon.allCases, id: \.self) { icon in
                ZStack {
                    Circle()
                        .stroke(Color.bb.selection, lineWidth: smallIconOutlineLineWidth)
                        .opacity(viewModel.shoppingList.icon == icon ? 1 : 0)
                        .frame(width: smallIconOutlineSize, height: smallIconOutlineSize)
                    
                    icon.image
                        .resizable()
                        .scaledToFit()
                        .frame(width: smallIconSize, height: smallIconSize)
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.white, viewModel.shoppingList.color.color)
                }
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
        .background(Color.bb.sheet.section.background)
        .cornerRadius(fieldCornerRadius)
    }
}

// MARK: - Preview

#Preview("Light") {
    let dataManager = DataManager(useCloud: false,
                                  coreDataStack: MockCoreDataStack(),
                                  repository: MockDataRepository(lists: []))
    let preferences = MockAppPreferences()
    let coordinator = AppCoordinator(preferences: preferences)
    let viewModel = ShoppingListSettingsViewModel(
        list: MockDataRepository.list1,
        dataManager: dataManager,
        coordinator: coordinator)
    
    ShoppingListSettingsView(viewModel: viewModel)
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    let dataManager = DataManager(useCloud: false,
                                  coreDataStack: MockCoreDataStack(),
                                  repository: MockDataRepository(lists: []))
    let preferences = MockAppPreferences()
    let coordinator = AppCoordinator(preferences: preferences)
    let viewModel = ShoppingListSettingsViewModel(
        list: MockDataRepository.list1,
        dataManager: dataManager,
        coordinator: coordinator)
    
    ShoppingListSettingsView(viewModel: viewModel)
        .preferredColorScheme(.dark)
}
