//
//  DeletedItemsView.swift
//  BuyBuy
//
//  Created by MDW on 14/06/2025.
//

import SwiftUI

struct DeletedItemsView: View {
    @StateObject var viewModel: DeletedItemsViewModel
    @State private var showDeleteAllItemsAlert = false
    
    init(viewModel: DeletedItemsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if let items = viewModel.items, items.count > 0 {
                List {
                    Section(header:
                        Text("deleted_items_info")
                            .foregroundColor(Color.bb.text.tertiary)
                            .font(.regularDynamic(style: .subheadline))
                            .padding(.bottom, 4)
                    ) {
                        ForEach(items) { item in
                            itemView(item: item)
                        }
                    }
                }
                .listStyle(.plain)
                .animation(.default, value: items)
            } else {
                emptyView()
            }
        }
        .toolbar {
            toolbarContent
        }
        .navigationTitle("recently_deleted")
        .navigationBarTitleDisplayMode(.large)
        .onReceive(viewModel.coordinator.eventPublisher) { event in
            switch event {
            case .shoppingItemImageChanged:
                Task { await viewModel.loadItems() }
            default: break
            }
        }
        .onAppear {
            viewModel.startObserving()
        }
        .onDisappear {
            viewModel.stopObserving()
        }
        .alert("delete_all_items_in_trash_title",
               isPresented: $showDeleteAllItemsAlert) {
            Button("delete", role: .destructive) {
                Task {
                    await viewModel.deleteAllItems()
                }
            }
            Button("cancel", role: .cancel) { }
        } message: {
            Text("delete_all_items_in_trash_message")
        }
        .task {
            await viewModel.loadItems()
        }
    }
    
    private func itemView(item: ShoppingItem) -> some View {
        return ShoppingItemRow(
            item: item,
            thumbnail: viewModel.thumbnail(for: item.imageIDs.first),
            state: false,
            onToggleStatus: { _ in },
            onRowTap: { _ in },
            onThumbnailTap: { _, _ in }
        )
        .contextMenu {
            Button {
                viewModel.openShoppingListSelector(for: item.id)
            } label: {
                Label("restore", systemImage: "list.bullet.clipboard.fill")
            }
            
            Button(role: .destructive) {
                Task {
                    await viewModel.deleteItem(with: item.id)
                }
            } label: {
                Label("delete", systemImage: "trash.fill")
            }
        }
        .swipeActions(edge: .leading, allowsFullSwipe: false) {
            Button {
                viewModel.openShoppingListSelector(for: item.id)
            } label: {
                Label("restore", systemImage: "list.bullet.clipboard.fill")
            }
            .tint(.blue)
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive) {
                Task {
                    await viewModel.deleteItem(with: item.id)
                }
            } label: {
                Label("delete", systemImage: "trash.fill")
            }
        }
    }
    
    private var toolbarContent: some ToolbarContent {
        Group {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Menu {
                    Button(role: .destructive) {
                        showDeleteAllItemsAlert = true
                    } label: {
                        Label("delete_all", systemImage: "trash")
                    }
                    .disabled(viewModel.items == nil || viewModel.items?.count == 0)
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
                .disabled(viewModel.items == nil)
                // .accessibilityLabel("More options")
            }
        }
    }
    
    @ViewBuilder
    private func emptyView() -> some View {
        if viewModel.items != nil {
            GeometryReader { geometry in
                let baseSize = min(geometry.size.width, geometry.size.height)
                
                VStack(spacing: 50) {
                    AnimatedIconView(
                        image: Image(systemName: "trash.fill"),
                        color: Color.bb.text.tertiary.opacity(0.5),
                        size: baseSize * 0.5,
                        response: 0.8,
                        dampingFraction: 0.3
                    )
                    
                    Text("no_deleted_items")
                        .font(.boldDynamic(style: .title2))
                        .foregroundColor(.bb.text.tertiary)
                        .multilineTextAlignment(.center)
                    
                    Text("deleted_items_info")
                        .font(.boldDynamic(style: .headline))
                        .foregroundColor(.bb.text.tertiary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .position(x: geometry.size.width * 0.5, y: geometry.size.height * 0.5)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 40)
        } else {
            ProgressView()
                .padding()
        }
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
    let viewModel = DeletedItemsViewModel(dataManager: dataManager,
                                          coordinator: coordinator)
    
    NavigationStack {
        DeletedItemsView(viewModel: viewModel)
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
    let viewModel = DeletedItemsViewModel(dataManager: dataManager,
                                          coordinator: coordinator)
    
    NavigationStack {
        DeletedItemsView(viewModel: viewModel)
    }
    .preferredColorScheme(.dark)
}

#Preview("Light/empty") {
    let dataManager = DataManager(useCloud: false,
                                  coreDataStack: MockCoreDataStack(),
                                  imageStorage: MockImageStorage(),
                                  fileStorage: MockFileStorage(),
                                  repository: MockDataRepository(deletedItems: []))
    let preferences = MockAppPreferences()
    let coordinator = AppCoordinator(preferences: preferences)
    let viewModel = DeletedItemsViewModel(dataManager: dataManager,
                                          coordinator: coordinator)
    
    NavigationStack {
        DeletedItemsView(viewModel: viewModel)
    }
    .preferredColorScheme(.light)
}

#Preview("Dark/empty") {
    let dataManager = DataManager(useCloud: false,
                                  coreDataStack: MockCoreDataStack(),
                                  imageStorage: MockImageStorage(),
                                  fileStorage: MockFileStorage(),
                                  repository: MockDataRepository(deletedItems: []))
    let preferences = MockAppPreferences()
    let coordinator = AppCoordinator(preferences: preferences)
    let viewModel = DeletedItemsViewModel(dataManager: dataManager,
                                          coordinator: coordinator)
    
    NavigationStack {
        DeletedItemsView(viewModel: viewModel)
    }
    .preferredColorScheme(.dark)
}
