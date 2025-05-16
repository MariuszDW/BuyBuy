//
//  ShoppingListView.swift
//  BuyBuy
//
//  Created by MDW on 14/05/2025.
//

import SwiftUI

struct ShoppingListView: View {
    @ObservedObject var viewModel: ShoppingListViewModel
    @EnvironmentObject var dependencies: AppDependencies
    
    var designSystem: DesignSystem {
        return dependencies.designSystem
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

struct ShoppingListView_Previews: PreviewProvider {
    static var previews: some View {
        let mockRepository = MockShoppingListRepository()
        let coordinator = AppCoordinator(dependencies: AppDependencies())
        let viewModel = ShoppingListViewModel(coordinator: coordinator, repository: mockRepository)

        Group {
            ShoppingListView(viewModel: viewModel)
                .environmentObject(AppDependencies())
                .preferredColorScheme(.light)

            ShoppingListView(viewModel: viewModel)
                .environmentObject(AppDependencies())
                .preferredColorScheme(.dark)
        }
    }

    private struct MockShoppingListRepository: ShoppingListRepositoryProtocol {
        func fetchList() -> ShoppingList? {
            ShoppingList(
                id: UUID(),
                name: "Mock List",
                items: [
                    ShoppingItem(id: UUID(), name: "Milk", status: .active),
                    ShoppingItem(id: UUID(), name: "Bread", status: .done)
                ]
            )
        }

        func addItem(_ item: ShoppingItem) {}
        func updateItem(_ item: ShoppingItem) {}
        func removeItem(with id: UUID) {}
    }
}

