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
            ForEach(viewModel.sections, id: \.self) { section in
                let items = list.items(withStatus: section.itemStatus)
                if !items.isEmpty {
                    Section(header: sectionHeader(section: section)) {
                        ForEach(items) { item in
                            Text(item.name)
                        }
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
    private func sectionHeader(section: ShoppingListSection) -> some View {
        HStack(spacing: 8) {
            Image(systemName: section.systemImage)
                .font(designSystem.fonts.boldDynamic(style: .title3))
                .foregroundColor(section.color)
            Text(section.title)
                .font(designSystem.fonts.boldDynamic(style: .title3))
                .foregroundColor(section.color)
                .opacity(0.6)
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
