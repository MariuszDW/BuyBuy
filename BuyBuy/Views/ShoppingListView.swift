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
            ForEach(viewModel.sections, id: \.status) { section in
                let items = list.items(withStatus: section.status)
                Section(header: sectionHeader(section: section, sectionItemCount: items.count)) {
                    if !section.isCollapsed {
                        ForEach(items) { item in
                            ShoppingItemRow(item: item) { toggledItem in
                                viewModel.toggleStatus(for: toggledItem)
                            }
                        }
                    }
                }
            }
        }
        .listStyle(.plain)
        // .animation(.easeInOut, value: list.items)
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
    private func sectionHeader(section: ShoppingListSection, sectionItemCount: Int) -> some View {
        let title: String = section.isCollapsed ? section.title + " (\(sectionItemCount))" : section.title
        
        HStack(spacing: 8) {
            Image(systemName: section.systemImage)
                .font(designSystem.fonts.boldDynamic(style: .title3))
                .foregroundColor(section.color)
            
            Text(title)
                .font(designSystem.fonts.boldDynamic(style: .title3))
                .foregroundColor(section.color)
                .opacity(0.7)
            
            Spacer()
            
            Button {
                withAnimation {
                    viewModel.toggleCollapse(ofSection: section)
                }
            } label: {
                Image(systemName: section.isCollapsed ? "chevron.down" : "chevron.up")
                    .font(designSystem.fonts.boldDynamic(style: .body))
                    .foregroundColor(.gray)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.top, 8)
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
