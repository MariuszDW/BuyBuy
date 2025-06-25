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
                Section(header: restoreItemInfoHeader) {
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
            }
            .listStyle(.plain)
            .navigationTitle("shopping_lists")
            .navigationBarTitleDisplayMode(.large)
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
    
    var restoreItemInfoHeader: some View {
        Text("restore_item_info")
            .foregroundColor(.bb.text.tertiary)
            .font(.regularDynamic(style: .subheadline))
            .padding(.bottom, 4)
            .textCase(nil)
    }
}

// MARK: - Preview

#Preview("Light/items") {
    let dataManager = DataManager(useCloud: false,
                                  coreDataStack: MockCoreDataStack(),
                                  imageStorage: MockImageStorage(),
                                  fileStorage: MockFileStorage(),
                                  repository: MockDataRepository())
    let preferences = MockAppPreferences()
    let coordinator = AppCoordinator(preferences: preferences)
    let viewModel = ShoppingListSelectorViewModel(itemIDToRestore: MockDataRepository.deletedItems[0].id,
                                                  dataManager: dataManager,
                                                  coordinator: coordinator)
    
    NavigationStack {
        ShoppingListSelectorView(viewModel: viewModel)
    }
    .preferredColorScheme(.light)
}

#Preview("Dark/items") {
    let dataManager = DataManager(useCloud: false,
                                  coreDataStack: MockCoreDataStack(),
                                  imageStorage: MockImageStorage(),
                                  fileStorage: MockFileStorage(),
                                  repository: MockDataRepository())
    let preferences = MockAppPreferences()
    let coordinator = AppCoordinator(preferences: preferences)
    let viewModel = ShoppingListSelectorViewModel(itemIDToRestore: MockDataRepository.deletedItems[0].id,
                                                  dataManager: dataManager,
                                                  coordinator: coordinator)
    
    NavigationStack {
        ShoppingListSelectorView(viewModel: viewModel)
    }
    .preferredColorScheme(.dark)
}
