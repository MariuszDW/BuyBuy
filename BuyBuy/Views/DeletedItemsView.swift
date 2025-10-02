//
//  DeletedItemsView.swift
//  BuyBuy
//
//  Created by MDW on 14/06/2025.
//

import SwiftUI
import Combine

struct DeletedItemsView: View {
    @StateObject var viewModel: DeletedItemsViewModel
    private var hapticEngine: HapticEngineProtocol
    @State private var showDeleteAllItemsAlert = false
    @State private var forceRefreshDiabled = false
    
    init(viewModel: DeletedItemsViewModel, hapticEngine: HapticEngineProtocol) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.hapticEngine = hapticEngine
    }
    
    var body: some View {
        VStack(spacing: 0) {
            contentView
        }
        .toolbar { toolbarContent }
        .navigationTitle("recently_deleted")
        .navigationBarTitleDisplayMode(.large)
        .onReceive(viewModel.eventPublisher) { event in
            handleEvent(event)
        }
        .onAppear { viewModel.startObserving() }
        .onDisappear { viewModel.stopObserving() }
        .alert("delete_all_items_in_trash_title", isPresented: $showDeleteAllItemsAlert) {
            deleteAllAlertButtons
        } message: {
            Text("delete_all_items_in_trash_message")
        }
        .task { await viewModel.loadItems() }
    }

    @ViewBuilder
    private var contentView: some View {
        if let _ = viewModel.items, !viewModel.items!.isEmpty {
            deletedItemsList
        } else {
            noContnetView
                .onTapGesture { Task { await forceRefresh() } }
        }
    }

    private var deletedItemsList: some View {
        List {
            Section(header: Text("deleted_items_info")
                .foregroundColor(.bb.text.tertiary)
                .font(.regularDynamic(style: .callout))
            ) {
                EmptyView()
            }

            ForEach(viewModel.sections) { section in
                Section(header: Text(section.deletedDate.localizedString(dateStyle: .long))
                    .foregroundColor(.bb.text.tertiary)
                    .font(.regularDynamic(style: .footnote))
                ) {
                    ForEach(section.items) { item in
                        itemView(item: item)
                    }
                }
            }
        }
        .listStyle(.grouped)
        .animation(.default, value: viewModel.items)
        .refreshable { await forceRefresh() }
    }

    private var deleteAllAlertButtons: some View {
        Group {
            Button("delete", role: .destructive) {
                Task { await viewModel.deleteAllItems() }
            }
            Button("cancel", role: .cancel) { }
        }
    }

    private func handleEvent(_ event: AppEvent) {
        switch event {
        case .shoppingItemEdited:
            Task { await viewModel.loadItems() }
        default: break
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
                    hapticEngine.playItemDeleted()
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
                    hapticEngine.playItemDeleted()
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
                        hapticEngine.playItemDeleted()
                        showDeleteAllItemsAlert = true
                    } label: {
                        Label("delete_all", systemImage: "trash")
                    }
                    .disabled(viewModel.items == nil || viewModel.items?.count == 0)
                } label: {
                    CircleIconView(systemName: "ellipsis")
                }
                .disabled(viewModel.items == nil)
            }
        }
    }
    
    @ViewBuilder
    private var noContnetView: some View {
        if viewModel.items != nil {
            NoContnetView(title: String(localized: "no_deleted_items"),
                          message: String(localized: "deleted_items_info"),
                          image: Image(systemName: "trash.fill"),
                          color: Color.bb.text.tertiary)
        } else {
            ProgressView()
                .padding()
        }
    }
    
    private func forceRefresh() async {
        guard forceRefreshDiabled == false else { return }
        forceRefreshDiabled = true
        await viewModel.loadItems(fullRefresh: true)
        try? await Task.sleep(for: .seconds(1))
        forceRefreshDiabled = false
    }
}

// MARK: - Preview

#Preview("Light/items") {
    let dataManager = DataManager(useCloud: false,
                                  repository: MockDataRepository())
    let preferences = MockAppPreferences()
    let coordinator = AppCoordinator(preferences: preferences)
    let viewModel = DeletedItemsViewModel(dataManager: dataManager,
                                          coordinator: coordinator)
    let mockHapticEngine = MockHapticEngine()
    
    NavigationStack {
        DeletedItemsView(viewModel: viewModel, hapticEngine: mockHapticEngine)
    }
    .preferredColorScheme(.light)
}

#Preview("Dark/items") {
    let dataManager = DataManager(useCloud: false,
                                  repository: MockDataRepository())
    let preferences = MockAppPreferences()
    let coordinator = AppCoordinator(preferences: preferences)
    let viewModel = DeletedItemsViewModel(dataManager: dataManager,
                                          coordinator: coordinator)
    let mockHapticEngine = MockHapticEngine()
    
    NavigationStack {
        DeletedItemsView(viewModel: viewModel, hapticEngine: mockHapticEngine)
    }
    .preferredColorScheme(.dark)
}

#Preview("Light/empty") {
    let dataManager = DataManager(useCloud: false,
                                  repository: MockDataRepository(deletedItems: []))
    let preferences = MockAppPreferences()
    let coordinator = AppCoordinator(preferences: preferences)
    let viewModel = DeletedItemsViewModel(dataManager: dataManager,
                                          coordinator: coordinator)
    let mockHapticEngine = MockHapticEngine()
    
    NavigationStack {
        DeletedItemsView(viewModel: viewModel, hapticEngine: mockHapticEngine)
    }
    .preferredColorScheme(.light)
}

#Preview("Dark/empty") {
    let dataManager = DataManager(useCloud: false,
                                  repository: MockDataRepository(deletedItems: []))
    let preferences = MockAppPreferences()
    let coordinator = AppCoordinator(preferences: preferences)
    let viewModel = DeletedItemsViewModel(dataManager: dataManager,
                                          coordinator: coordinator)
    let mockHapticEngine = MockHapticEngine()
    
    NavigationStack {
        DeletedItemsView(viewModel: viewModel, hapticEngine: mockHapticEngine)
    }
    .preferredColorScheme(.dark)
}
