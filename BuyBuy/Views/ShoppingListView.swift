//
//  ShoppingListView.swift
//  BuyBuy
//
//  Created by MDW on 14/05/2025.
//

import SwiftUI

struct ShoppingListView: View {
    @StateObject var viewModel: ShoppingListViewModel
    @EnvironmentObject var dependencies: AppDependencies

    var designSystem: DesignSystem {
        return dependencies.designSystem
    }

    init(viewModel: ShoppingListViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        Group {
            if let list = viewModel.list {
                listView(list)
            } else {
                emptyView()
            }
        }
        .navigationTitle(viewModel.list?.name ?? "Shopping list")
        .navigationBarTitleDisplayMode(.large)
    }

    @ViewBuilder
    private func listView(_ list: ShoppingList) -> some View {
        List {
            let pendingItems = list.items(withStatus: .pending)
            if !pendingItems.isEmpty {
                Section(header: sectionHeader("Pending", systemImage: "clock", color: .orange)) {
                    ForEach(pendingItems) { item in
                        Text(item.name)
                    }
                }
            }

            let purchasedItems = list.items(withStatus: .purchased)
            if !purchasedItems.isEmpty {
                Section(header: sectionHeader("Purchased", systemImage: "checkmark.square", color: .green)) {
                    ForEach(purchasedItems) { item in
                        Text(item.name)
                    }
                }
            }

            let inactiveItems = list.items(withStatus: .inactive)
            if !inactiveItems.isEmpty {
                Section(header: sectionHeader("Inactive", systemImage: "zzz", color: .red)) {
                    ForEach(inactiveItems) { item in
                        Text(item.name)
                    }
                }
            }
        }
        .listStyle(.plain)
    }

    @ViewBuilder
    private func emptyView() -> some View {
        VStack(spacing: 20) {
            Text("Can't find a shopping list.")
                .font(designSystem.fonts.boldDynamic(style: .body))
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
    
    @ViewBuilder
    private func sectionHeader(_ title: String, systemImage: String, color: Color) -> some View {
        HStack(spacing: 10) {
            Image(systemName: systemImage)
                .font(designSystem.fonts.boldDynamic(style: .title2))
                .foregroundColor(color)
            Text(title)
                .font(designSystem.fonts.boldDynamic(style: .title2))
                .foregroundColor(color)
        }
        .padding(.top, 16)
        .padding(.bottom, 4)
    }
}

// MARK: - Preview

#Preview("Light Mode") {
    let dependencies = AppDependencies()
    let coordinator = AppCoordinator(dependencies: dependencies)
    let viewModel = ShoppingListViewModel(coordinator: coordinator,
                                          repository: MockShoppingListRepository())

    NavigationStack {
        ShoppingListView(viewModel: viewModel)
            .environmentObject(dependencies)
    }
    .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    let dependencies = AppDependencies()
    let coordinator = AppCoordinator(dependencies: dependencies)
    let viewModel = ShoppingListViewModel(coordinator: coordinator,
                                          repository: MockShoppingListRepository())

    NavigationStack {
        ShoppingListView(viewModel: viewModel)
            .environmentObject(dependencies)
    }
    .preferredColorScheme(.dark)
}

// MARK: - Preview Mock

private struct MockShoppingListRepository: ShoppingListRepositoryProtocol {
    func getItems() -> ShoppingList? {
        ShoppingList(
            name: "Mock List",
            items: [
                ShoppingItem(name: "Onion", status: .purchased),
                ShoppingItem(name: "Cheese", status: .inactive),
                ShoppingItem(name: "Milk", status: .pending),
                ShoppingItem(name: "Carrot", status: .pending),
                ShoppingItem(name: "Bread", status: .purchased),
                ShoppingItem(name: "Eggs", status: .inactive)
            ],
            order: 0
        )
    }

    func addItem(_ item: ShoppingItem) {}
    func updateItem(_ item: ShoppingItem) {}
    func removeItem(with id: UUID) {}
}
