//
//  ShoppingListView.swift
//  BuyBuy
//
//  Created by MDW on 14/05/2025.
//

import SwiftUI

struct ShoppingListView: View {
    @StateObject var viewModel: ShoppingListViewModel
    
    @State private var localEditMode: EditMode = .inactive
    
    var body: some View {
        Group {
            if let list = viewModel.list {
                listView(list)
                    .environment(\.editMode, $localEditMode)
                bottomPanel
            } else {
                emptyView()
            }
        }
        .navigationTitle(viewModel.list?.name ?? "")
        .navigationBarTitleDisplayMode(.large)
        .task {
            await viewModel.loadList()
        }
    }
    
    @ViewBuilder
    private func listView(_ list: ShoppingList) -> some View {
        List {
            ForEach(viewModel.sections, id: \.status) { section in
                let items = list.items(withStatus: section.status)
                Section(header: sectionHeader(section: section, sectionItemCount: items.count)) {
                    if !section.isCollapsed {
                        ForEach(items) { item in
                            ShoppingItemRow(item: item) { [weak viewModel] toggledItem in
                                Task {
                                    await viewModel?.toggleStatus(for: toggledItem)
                                }
                            }
                        }
                    }
                }
            }
        }
        .listStyle(.plain)
    }
    
    private var bottomPanel: some View {
        HStack {
            Button(action: {
                if let listID = viewModel.list?.id {
                    localEditMode = .inactive
                    viewModel.openNewItemSettings(listID: listID)
                }
            }) {
                Label("Add item", systemImage: "plus.circle")
            }
            .disabled(localEditMode.isEditing)
            
            Spacer()
        }
        .padding()
    }
    
    @ViewBuilder
    private func emptyView() -> some View {
        VStack(spacing: 20) {
            Text("Can't find a shopping list.")
                .font(.boldDynamic(style: .body))
                .buttonStyle(.borderedProminent)
        }
        .padding()
    }
    
    @ViewBuilder
    private func sectionHeader(section: ShoppingListSection, sectionItemCount: Int) -> some View {
        let title: String = section.isCollapsed ? section.title + " (\(sectionItemCount))" : section.title
        
        HStack(spacing: 8) {
            Image(systemName: section.systemImage)
                .font(.boldDynamic(style: .title3))
                .foregroundColor(section.color)
            
            Text(title)
                .font(.boldDynamic(style: .title3))
                .foregroundColor(section.color)
                .opacity(0.7)
            
            Spacer()
            
            Button {
                withAnimation {
                    viewModel.toggleCollapse(ofSection: section)
                }
            } label: {
                Image(systemName: section.isCollapsed ? "chevron.down" : "chevron.up")
                    .font(.boldDynamic(style: .body))
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
    let repository = MockShoppingListsRepository()
    let coordinator = AppCoordinator(dependencies: AppDependencies())
    let viewModel = ShoppingListViewModel(listID: UUID(),
                                          repository: repository,
                                          coordinator: coordinator)
    
    NavigationStack {
        ShoppingListView(viewModel: viewModel)
    }
    .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    let repository = MockShoppingListsRepository()
    let coordinator = AppCoordinator(dependencies: AppDependencies())
    let viewModel = ShoppingListViewModel(listID: UUID(),
                                          repository: repository,
                                          coordinator: coordinator)
    
    NavigationStack {
        ShoppingListView(viewModel: viewModel)
    }
    .preferredColorScheme(.dark)
}
