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
                Section {
                    statusView
                }

                Section(header: sectionHeader(String(localized: "restore_item_destination_header"))) {
                    ForEach(viewModel.shoppingLists) { list in
                        Button {
                            Task {
                                await viewModel.moveDeletedItem(toListID: list.id)
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
            .listStyle(.insetGrouped)
            .navigationTitle("restore_item")
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
    
    @ViewBuilder
    private func sectionHeader(_ text: String) -> some View {
        Text(text)
            .foregroundColor(.bb.text.tertiary)
            .font(.regularDynamic(style: .subheadline))
            .padding(.bottom, 4)
            .textCase(nil)
    }
    
    private var statusView: some View {
        HStack {
            Text("status")
            Spacer()
            Menu {
                ForEach(ShoppingItemStatus.allCases, id: \.self) { status in
                    Button {
                        viewModel.selectedStatus = status
                    } label: {
                        Label(status.localizedName, systemImage: status.imageSystemName)
                            .foregroundColor(status.color)
                    }
                }
            } label: {
                let status = viewModel.selectedStatus
                HStack(spacing: 8) {
                    status.image
                        .foregroundColor(status.color)
                    Text(status.localizedName)
                        .foregroundColor(status.color)
                    Image(systemName: "chevron.up.chevron.down")
                        .foregroundColor(.bb.selection)
                        .padding(.leading, 4)
                }
            }
        }
    }
}

// MARK: - Preview

#Preview("Light/items") {
    let dataManager = DataManager(useCloud: false,
                                  repository: MockDataRepository())
    let preferences = MockAppPreferences()
    let coordinator = AppCoordinator(preferences: preferences)
    let viewModel = ShoppingListSelectorViewModel(
        itemIDToRestore: MockDataRepository.deletedItems[0].id,
        dataManager: dataManager,
        coordinator: coordinator
    )
    
    NavigationStack {
        ShoppingListSelectorView(viewModel: viewModel)
    }
    .preferredColorScheme(.light)
}

#Preview("Dark/items") {
    let dataManager = DataManager(useCloud: false,
                                  repository: MockDataRepository())
    let preferences = MockAppPreferences()
    let coordinator = AppCoordinator(preferences: preferences)
    let viewModel = ShoppingListSelectorViewModel(
        itemIDToRestore: MockDataRepository.deletedItems[0].id,
        dataManager: dataManager,
        coordinator: coordinator
    )
    
    NavigationStack {
        ShoppingListSelectorView(viewModel: viewModel)
    }
    .preferredColorScheme(.dark)
}
