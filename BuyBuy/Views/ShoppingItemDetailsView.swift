//
//  ShoppingItemDetailsView.swift
//  BuyBuy
//
//  Created by MDW on 20/05/2025.
//

import SwiftUI

struct ShoppingItemDetailsView: View {
    @StateObject var viewModel: ShoppingItemDetailsViewModel
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isNameFocused: Bool
    @FocusState private var isNoteFocused: Bool
    
    var body: some View {
        NavigationStack {
            List {
                statusSection
                namesSection
            }
            .safeAreaInset(edge: .bottom) {
                if isNameFocused || isNoteFocused {
                    HStack {
                        Spacer()
                        Button {
                            clearTextFieldFocus()
                        } label: {
                            Image(systemName: "keyboard.chevron.compact.down")
                                .font(.regularDynamic(style: .title2))
                                .foregroundColor(.bb.accent)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(Color.bb.background.opacity(0.5))
                                )
                        }
                    }
                }
            }
            .task {
                isNameFocused = viewModel.isNew
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Item details")
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
                    .disabled(viewModel.shoppingItem.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
    
    private var statusSection: some View {
        Section {
            HStack {
                Text("Status")
                Spacer()
                Menu {
                    ForEach(ShoppingItemStatus.allCases, id: \.self) { status in
                        Button {
                            viewModel.shoppingItem.status = status
                        } label: {
                            Label(status.localizedName, systemImage: status.imageSystemName)
                                .foregroundColor(status.color)
                        }
                    }
                } label: {
                    let status = viewModel.shoppingItem.status
                    HStack(spacing: 8) {
                        status.image
                            .foregroundColor(status.color)
                        Text(status.localizedName)
                            .foregroundColor(status.color)
                        Image(systemName: "chevron.up.chevron.down")
                            .foregroundColor(.bb.accent)
                            .padding(.leading, 8)
                    }
                }
            }
        }
    }
    
    private var namesSection: some View {
        Section {
            TextField("Enter name", text: $viewModel.shoppingItem.name, axis: .vertical)
                .lineLimit(4)
                .multilineTextAlignment(.leading)
                .font(.boldDynamic(style: .title3))
                .focused($isNameFocused)
                .onSubmit {
                    isNameFocused = false
                }
            
            TextField("Enter note", text: $viewModel.shoppingItem.note, axis: .vertical)
                .lineLimit(8)
                .multilineTextAlignment(.leading)
                .font(.regularDynamic(style: .body))
                .focused($isNoteFocused)
                .onSubmit {
                    isNoteFocused = false
                }
        }
    }
    
    private func clearTextFieldFocus() {
        isNameFocused = false
        isNoteFocused = false
    }
}

// MARK: - Preview

#Preview("Light") {
    let repository = MockShoppingListsRepository()
    let viewModel = ShoppingItemDetailsViewModel(
        item: MockShoppingListsRepository.list1.items.first!,
        repository: repository,
        coordinator: AppCoordinator(dependencies: AppDependencies()),
        onSave: {})
    
    ShoppingItemDetailsView(viewModel: viewModel)
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    let repository = MockShoppingListsRepository()
    let viewModel = ShoppingItemDetailsViewModel(
        item: MockShoppingListsRepository.list1.items.first!,
        repository: repository,
        coordinator: AppCoordinator(dependencies: AppDependencies()),
        onSave: {})
    
    ShoppingItemDetailsView(viewModel: viewModel)
        .preferredColorScheme(.dark)
}
