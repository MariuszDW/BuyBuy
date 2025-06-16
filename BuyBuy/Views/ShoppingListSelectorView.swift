//
//  ShoppingListSelectorView.swift
//  BuyBuy
//
//  Created by MDW on 15/06/2025.
//

import SwiftUI

struct ShoppingListSelectorView: View {
    @StateObject var viewModel: ShoppingListSelectorViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(viewModel: ShoppingListSelectorViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            List {
                Text("restore_item_info")
                    .foregroundColor(.bb.text.tertiary)
                    .font(.regularDynamic(style: .callout))
                    .padding(.bottom, 12)
                
                ForEach(viewModel.shoppingLists) { list in
                    Button {
                        Task {
                            await viewModel.moveDeletedItem(itemID: viewModel.itemIDToRestore, toListID: list.id)
                            dismiss()
                        }
                    } label: {
                        HStack {
                            Image(systemName: list.icon.rawValue)
                                .symbolRenderingMode(.palette)
                                .foregroundStyle(.white, list.color.color)
                                .font(.regularDynamic(style: .largeTitle))
                            
                            Text(list.name)
                                .foregroundColor(.bb.text.primary)
                                .font(.regularDynamic(style: .title3))
                                .multilineTextAlignment(.leading)
                                .lineLimit(4)
                        }
                    }
                }
            }
            .navigationTitle("shopping_lists")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("cancel") {
                        dismiss()
                    }
                }
            }
            .task {
                await viewModel.loadLists()
            }
        }
    }
}

// MARK: - Preview

#Preview("Light/items") {
    let dataManager = DataManager(repository: MockDataRepository(),
                                  imageStorage: MockImageStorage())
    let coordinator = AppCoordinator(dependencies: AppDependencies())
    let viewModel = ShoppingListSelectorViewModel(itemIDToRestore: MockDataRepository.deletedItems[0].id,
                                                  dataManager: dataManager,
                                                  coordinator: coordinator)
    
    NavigationStack {
        ShoppingListSelectorView(viewModel: viewModel)
    }
    .preferredColorScheme(.light)
}

#Preview("Dark/items") {
    let dataManager = DataManager(repository: MockDataRepository(),
                                  imageStorage: MockImageStorage())
    let coordinator = AppCoordinator(dependencies: AppDependencies())
    let viewModel = ShoppingListSelectorViewModel(itemIDToRestore: MockDataRepository.deletedItems[0].id,
                                                  dataManager: dataManager,
                                                  coordinator: coordinator)
    
    NavigationStack {
        ShoppingListSelectorView(viewModel: viewModel)
    }
    .preferredColorScheme(.dark)
}
