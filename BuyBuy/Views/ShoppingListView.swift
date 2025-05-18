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
        .navigationBarTitleDisplayMode(.inline)
    }
    
    @ViewBuilder
    private func listView(_ list: ShoppingList) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(list.name)
                .font(.largeTitle)
                .bold()
            
            if list.items.isEmpty {
                Text("Empty list")
                    .foregroundColor(.secondary)
            } else {
                List(list.items) { item in
                    Text(item.name)
                }
            }
            
            Spacer()
            
            Button("Back") {
                viewModel.back()
            }
            .padding()
        }
        .padding()
    }
    
    @ViewBuilder
    private func emptyView() -> some View {
        VStack(spacing: 20) {
            Text("Can't find a shopping list.")
                .font(.title2)
                .foregroundColor(.red)
            
            Button("Back") {
                viewModel.back()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

// MARK: - Preview

#Preview("Light Mode") {
    let coordinator = AppCoordinator(dependencies: AppDependencies())
    let viewModel = ShoppingListViewModel(coordinator: coordinator,
                                          repository: MockShoppingListRepository())

    ShoppingListView(viewModel: viewModel)
        .environmentObject(AppDependencies())
        .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    let coordinator = AppCoordinator(dependencies: AppDependencies())
    let viewModel = ShoppingListViewModel(coordinator: coordinator,
                                          repository: MockShoppingListRepository())

    ShoppingListView(viewModel: viewModel)
        .environmentObject(AppDependencies())
        .preferredColorScheme(.dark)
}

// MARK: - Preview Mock

private struct MockShoppingListRepository: ShoppingListRepositoryProtocol {
    func fetchList() -> ShoppingList? {
        ShoppingList(
            id: UUID(),
            name: "Mock List",
            items: [
                ShoppingItem(id: UUID(), name: "Milk", status: .pending),
                ShoppingItem(id: UUID(), name: "Bread", status: .purchased)
            ],
            order: 0
        )
    }

    func addItem(_ item: ShoppingItem) {}
    func updateItem(_ item: ShoppingItem) {}
    func removeItem(with id: UUID) {}
}
