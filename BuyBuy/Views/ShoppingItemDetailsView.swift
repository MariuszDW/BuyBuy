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
    
    @FocusState private var focusedNameField: Bool?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    nameSection
                }
                .padding()
            }
            .navigationTitle("Item settings")
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
    
    private var nameSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            TextField(
                "Item name",
                text: $viewModel.shoppingItem.name
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
