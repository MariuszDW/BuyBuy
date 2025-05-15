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
            Text("Can't found a shopping list.")
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
    static let mockList = ShoppingList(
        id: UUID(),
        name: "Mock list",
        items: []
    )
    
    static var previews: some View {
        let mockViewModel = ShoppingListViewModel(
            listID: mockList.id, coordinator: AppCoordinator(), repository: ShoppingListRepository())

        Group {
            ShoppingListView(viewModel: mockViewModel)
                .preferredColorScheme(.light)
                .environmentObject(AppDependencies())

            ShoppingListView(viewModel: mockViewModel)
                .preferredColorScheme(.dark)
                .environmentObject(AppDependencies())
        }
    }
}
