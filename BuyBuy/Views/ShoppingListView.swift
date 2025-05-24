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
        VStack {
            if let list = viewModel.list, !list.items.isEmpty {
                listView(list)
                    .environment(\.editMode, $localEditMode)
                    .listStyle(.grouped)
            } else {
                Spacer()
                emptyView()
                    .onAppear {
                        localEditMode = .inactive
                    }
            }
            
            Spacer()
            bottomPanel
        }
        .toolbar {
            toolbarContent
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
                let items = list.items(for: section.status)
                Section(header: sectionHeader(section: section, sectionItemCount: items.count)) {
                    if !section.isCollapsed {
                        itemsSection(items: items, section: section)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func itemsSection(items: [ShoppingItem], section: ShoppingListSection) -> some View {
        ForEach(items) { item in
            ShoppingItemRow(
                item: item,
                disabled: localEditMode == .active,
                onToggleStatus: { [weak viewModel] toggledItem in
                    Task {
                        await viewModel?.toggleStatus(for: toggledItem)
                    }
                },
                onRowTap: { tappedItem in
                    viewModel.openItemSettings(item: tappedItem)
                }
            )
            .contextMenu {
                Button {
                    viewModel.openItemSettings(item: item)
                } label: {
                    Label("Edit", systemImage: "square.and.pencil")
                }
                
                Button(role: .destructive) {
                    Task {
                        await handleDeleteTapped(for: item)
                    }
                } label: {
                    Label("Delete", systemImage: "trash.fill")
                }
            }
            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                Button(role: .destructive) {
                    Task {
                        await handleDeleteTapped(for: item)
                    }
                } label: {
                    Label("Delete", systemImage: "trash.fill")
                }
                
                Button {
                    viewModel.openItemSettings(item: item)
                } label: {
                    Label("Edit", systemImage: "square.and.pencil")
                }
                .tint(.blue)
            }
            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                ForEach(ShoppingItemStatus.allCases, id: \.self) { status in
                    if item.status != status {
                        Button {
                            Task {
                                await viewModel.setStatus(status, forItem: item)
                            }
                        } label: {
                            Label(status.rawValue, systemImage: status.imageSystemName)
                        }
                        .tint(status.color)
                    }
                }
            }
        }
        .onDelete { offsets in
            Task {
                await viewModel.deleteItems(atOffsets: offsets, section: section)
            }
        }
        .onMove { indices, newOffset in
            Task {
                await viewModel.moveItem(from: indices, to: newOffset, in: section.status)
            }
        }
    }
    
    private var toolbarContent: some ToolbarContent {
        Group {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button {
                    withAnimation {
                        localEditMode = (localEditMode == .active) ? .inactive : .active
                    }
                } label: {
                    Image(systemName: localEditMode == .active ? "checkmark" : "pencil.circle")
                }
                .disabled(viewModel.list?.items.isEmpty ?? true)
                .accessibilityLabel(localEditMode == .active ? "Done Editing" : "Edit")
            }
        }
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
        if let list = viewModel.list {
            GeometryReader { geometry in
                VStack(spacing: 50) {
                    Spacer()
                    
                    let iconSize = min(geometry.size.width, geometry.size.height) * 0.5
                    
                    AnimatedIconView(
                        image: list.icon.image,
                        color: list.color.color.opacity(0.4),
                        size: iconSize,
                        response: 0.8,
                        dampingFraction: 0.3
                    )
                    
                    Text("This shopping list is empty.")
                        .font(Font.boldDynamic(style: .title2))
                        .foregroundColor(.bb.grey75)
                        .multilineTextAlignment(.center)

                    Text("Use the 'Add item' button to add your first shopping item.")
                        .font(Font.boldDynamic(style: .headline))
                        .foregroundColor(.bb.grey75)
                        .multilineTextAlignment(.center)

                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .padding()
            }
        } else {
            ProgressView()
                .padding()
        }
    }
    
    @ViewBuilder
    private func sectionHeader(section: ShoppingListSection, sectionItemCount: Int) -> some View {
        let title: String = section.isCollapsed ? section.title + " (\(sectionItemCount))" : section.title
        
        HStack(spacing: 8) {
            section.image
                .font(.boldDynamic(style: .headline))
                .foregroundColor(section.color)
            
            Text(title)
                .font(.boldDynamic(style: .headline))
                .foregroundColor(section.color)
            
            Spacer()
            
            Button {
                withAnimation {
                    viewModel.toggleCollapse(ofSection: section)
                }
            } label: {
                Image(systemName: section.isCollapsed ? "chevron.down" : "chevron.up")
                    .font(.boldDynamic(style: .body))
                    .foregroundColor(.bb.text.primary)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.bottom, 4)
    }
    
    // MARK: - Private
    
    private func handleDeleteTapped(for item: ShoppingItem) async {
        Task {
            await viewModel.deleteItem(with: item.id)
        }
    }
}

// MARK: - Preview

#Preview("Light/items") {
    let repository = MockShoppingListsRepository()
    let coordinator = AppCoordinator(dependencies: AppDependencies())
    let viewModel = ShoppingListViewModel(listID: MockShoppingListsRepository.uuid1,
                                          repository: repository,
                                          coordinator: coordinator)
    
    NavigationStack {
        ShoppingListView(viewModel: viewModel)
    }
    .preferredColorScheme(.light)
}

#Preview("Dark/items") {
    let repository = MockShoppingListsRepository()
    let coordinator = AppCoordinator(dependencies: AppDependencies())
    let viewModel = ShoppingListViewModel(listID: MockShoppingListsRepository.uuid1,
                                          repository: repository,
                                          coordinator: coordinator)
    
    NavigationStack {
        ShoppingListView(viewModel: viewModel)
    }
    .preferredColorScheme(.dark)
}

#Preview("Light/empty") {
    let repository = MockShoppingListsRepository()
    let coordinator = AppCoordinator(dependencies: AppDependencies())
    let viewModel = ShoppingListViewModel(listID: MockShoppingListsRepository.uuid5,
                                          repository: repository,
                                          coordinator: coordinator)
    
    NavigationStack {
        ShoppingListView(viewModel: viewModel)
    }
    .preferredColorScheme(.light)
}

#Preview("Dark/empty") {
    let repository = MockShoppingListsRepository()
    let coordinator = AppCoordinator(dependencies: AppDependencies())
    let viewModel = ShoppingListViewModel(listID: MockShoppingListsRepository.uuid5,
                                          repository: repository,
                                          coordinator: coordinator)
    
    NavigationStack {
        ShoppingListView(viewModel: viewModel)
    }
    .preferredColorScheme(.dark)
}
