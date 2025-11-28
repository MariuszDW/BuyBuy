//
//  ShoppingListView.swift
//  BuyBuy
//
//  Created by MDW on 14/05/2025.
//

import SwiftUI

struct ShoppingListView: View {
    @StateObject var viewModel: ShoppingListViewModel
    private let hapticEngine: HapticEngineProtocol
    @State private var isEditMode: EditMode = .inactive
    @State private var showDeletePurchasedAlert = false
    @State private var forceRefreshDiabled = false
    @State private var selectedItemStatus: ShoppingItemStatus = .pending
    
    init(viewModel: ShoppingListViewModel, hapticEngine: HapticEngineProtocol) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.hapticEngine = hapticEngine
    }
    
    var body: some View {
        Group {
            if viewModel.itemCount() > 0 {
                itemsListView(with: viewModel.items(for: selectedItemStatus))
            } else {
                noContentView
                    .onAppear { isEditMode = .inactive }
                    .onTapGesture { Task { await forceRefresh() } }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .safeAreaInset(edge: .bottom) {
            if !isEditMode.isEditing {
                VStack(spacing: 14) {
                    if viewModel.list?.containsItemsWithPrice() ?? false {
                        costView()
                            .padding(.horizontal)
                    }
                    buttonRow()
                }
            } else {
                EmptyView()
            }
        }
        .toolbar { toolbarContent }
        .navigationTitle(viewModel.list?.name ?? "")
        .navigationBarTitleDisplayMode(.inline)
        .onReceive(viewModel.eventPublisher) { event in
            if case .shoppingItemEdited = event {
                Task { await viewModel.loadList() }
            }
        }
        .onAppear { viewModel.startObserving() }
        .onDisappear { viewModel.stopObserving() }
        .task { await viewModel.loadList() }
        .alert("delete_purchased_items_title",
               isPresented: $showDeletePurchasedAlert) {
            Button("delete", role: .destructive) {
                Task { await viewModel.deletePurchasedItems() }
            }
            Button("cancel", role: .cancel) { }
        } message: {
            Text("delete_purchased_items_message")
        }
    }
    
    @ViewBuilder
    private func itemsListView(with items: [ShoppingItem]) -> some View {
        List {
            categoryTitleView()
                .padding(.horizontal)
                .listRowSeparator(.hidden)
            
            ForEach(items, id: \.id) { item in
                itemView(with: item)
            }
            .onDelete { offsets in
                Task {
                    await viewModel.deleteItems(atOffsets: offsets, status: selectedItemStatus)
                }
            }
            .onMove { indices, newOffset in
                Task {
                    await viewModel.moveItem(from: indices, to: newOffset, in: selectedItemStatus)
                }
            }
        }
        .animation(.default, value: selectedItemStatus)
        .animation(.default, value: viewModel.list?.items)
        .environment(\.editMode, $isEditMode)
        .listStyle(.plain)
        .refreshable {
            await forceRefresh()
        }
    }
    
    private func categoryTitleView() -> some View {
        return HStack(spacing: 8) {
            selectedItemStatus.image
                .font(.boldDynamic(style: .headline))
                .foregroundColor(selectedItemStatus.color)
            
            Text(selectedItemStatus.localizedCategoryName)
                .font(.boldDynamic(style: .headline))
                .foregroundColor(selectedItemStatus.color)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(
            coloredCapsuleBackground(selectedItemStatus.color)
        )
    }
    
    private func itemView(with item: ShoppingItem) -> some View {
        return ShoppingItemRow(
            item: item,
            status: viewModel.visibleStatus(for: item),
            thumbnail: viewModel.thumbnail(for: item.imageIDs.first),
            state: isEditMode == .inactive,
            onToggleStatus: { toggledItemID in
                hapticEngine.playItemChecked()
                viewModel.setStatus(item.status.toggled(), itemID: toggledItemID, delay: 0.25)
            },
            onRowTap: { tappedItemID in
                viewModel.openItemDetails(for: tappedItemID)
            },
            onThumbnailTap: { selectedItemID, imageIndex in
                hapticEngine.playSelectionChanged()
                viewModel.openItemImagePreviews(for: selectedItemID, imageIndex: imageIndex)
            }
        )
        .contextMenu {
            Button {
                viewModel.openItemDetails(for: item.id)
            } label: {
                Label("edit", systemImage: "square.and.pencil")
            }
            
            Button(role: .destructive) {
                Task {
                    await handleDeleteTapped(with: item.id)
                }
            } label: {
                Label("delete", systemImage: "trash.fill")
            }
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive) {
                Task {
                    await handleDeleteTapped(with: item.id)
                }
            } label: {
                Label("delete", systemImage: "trash.fill")
            }
            
            Button {
                viewModel.openItemDetails(for: item.id)
            } label: {
                Label("edit", systemImage: "square.and.pencil")
            }
            .tint(.blue)
        }
        .swipeActions(edge: .leading, allowsFullSwipe: true) {
            ForEach(ShoppingItemStatus.allCases, id: \.self) { status in
                if status != selectedItemStatus {
                    Button {
                        hapticEngine.playItemChecked()
                        viewModel.setStatus(status, itemID: item.id, delay: 0.75)
                    } label: {
                        Label(status.localizedName, systemImage: status.imageSystemName)
                    }
                    .tint(status.color)
                }
            }
        }
    }
    
    private var toolbarContent: some ToolbarContent {
        Group {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                if !isEditMode.isEditing {
                    Button {
                        viewModel.openLoyaltyCards()
                    } label: {
                        CircleIconView(systemName: "creditcard.fill")
                    }
                }
                
                if isEditMode.isEditing {
                    Button("ok") {
                        isEditMode = .inactive
                    }
                }
                
                if !isEditMode.isEditing {
                    Menu {
                        Button {
                            isEditMode = .active
                        } label: {
                            Label("edit_list", systemImage: "pencil")
                        }
                        .disabled(viewModel.itemCount() == 0)
                        
                        Button {
                            viewModel.openListSettings()
                        } label: {
                            Label("list_settings", systemImage: "list.bullet.clipboard")
                        }
                        
                        Button {
                            viewModel.openExportListOptions()
                        } label: {
                            Label("export_list", systemImage: "square.and.arrow.up")
                        }
                        
                        Button(role: .destructive) {
                            hapticEngine.playItemDeleted()
                            showDeletePurchasedAlert = true
                        } label: {
                            Label("delete_purchased_items", systemImage: "trash")
                        }
                        .disabled(!viewModel.hasPurchasedItems)
                    } label: {
                        CircleIconView(systemName: "ellipsis")
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private var noContentView: some View {
        if let list = viewModel.list {
            NoContnetView(title: String(localized: "list_empty_view_title"),
                          message: String(localized: "list_empty_view_message"),
                          image: list.icon.image,
                          color: list.color.color)
        } else {
            ProgressView()
                .padding()
        }
    }
    
    @ViewBuilder
    private func buttonRow() -> some View {
        HStack {
            CapsuleButton(systemImage: "plus") {
                if let listID = viewModel.list?.id {
                    viewModel.openNewItemDetails(listID: listID, itemStatus: selectedItemStatus)
                }
            }

            Spacer()

            ForEach(ShoppingItemStatus.allCases, id: \.self) { status in
                CapsuleButton(
                    systemImage: status.imageSystemName,
                    badge: viewModel.itemCount(for: status),
                    badgeColor: status.color.hsb(saturation: 1.0, brightness: -0.07),
                    minWidth: 38,
                    highlighted: selectedItemStatus == status,
                ) {
                    withAnimation {
                        selectedItemStatus = status
                    }
                }
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 4)
    }
    
    @ViewBuilder
    private func costView() -> some View {
        let totalPriceOfPendingItems = viewModel.list?.totalPrice(for: .pending) ?? 0
        let totalPriceOfPurchasedItems = viewModel.list?.totalPrice(for: .purchased) ?? 0
        
        let pendingItemsIcon = ShoppingItemStatus.pending.image
            .font(.boldDynamic(style: .body))
            .lineLimit(1)
            .foregroundColor(ShoppingItemStatus.pending.color)
        
        let purchasedItemsIcon = ShoppingItemStatus.purchased.image
            .font(.boldDynamic(style: .body))
            .lineLimit(1)
            .foregroundColor(ShoppingItemStatus.purchased.color)
        
        let pendingItemsText = Text(totalPriceOfPendingItems.priceFormat)
            .font(.boldMonospaced(style: .body))
            .foregroundColor(ShoppingItemStatus.pending.color)
        
        let purchasedItemsText = Text(totalPriceOfPurchasedItems.priceFormat)
            .font(.boldMonospaced(style: .body))
            .foregroundColor(ShoppingItemStatus.purchased.color)
        
        HStack(spacing: 12) {
            Spacer()
            
            HStack(spacing: 6) {
                pendingItemsIcon
                pendingItemsText
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(
                coloredCapsuleBackground(ShoppingItemStatus.pending.color)
            )
            
            HStack(spacing: 5) {
                purchasedItemsIcon
                purchasedItemsText
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(
                coloredCapsuleBackground(ShoppingItemStatus.purchased.color)
            )
        }
    }
    
    @ViewBuilder
    private func coloredCapsuleBackground(_ color: Color) -> some View {
        ZStack {
            Capsule()
                .fill(Color.bb.background.opacity(0.7))
            
            Capsule()
                .fill(color.opacity(0.15))
                .overlay(
                    Capsule()
                        .stroke(color, lineWidth: 2)
                )
        }
    }
    
    // MARK: - Private
    
    private func handleDeleteTapped(with itemID: UUID) async {
        hapticEngine.playItemDeleted()
        await viewModel.moveItemToDeleted(with: itemID)
    }
    
    private func forceRefresh() async {
        guard forceRefreshDiabled == false else { return }
        forceRefreshDiabled = true
        await viewModel.loadList(fullRefresh: true)
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
    let viewModel = ShoppingListViewModel(listID: MockDataRepository.list1ID,
                                          dataManager: dataManager,
                                          coordinator: coordinator)
    let mockHapticEngine = MockHapticEngine()
    
    NavigationStack {
        ShoppingListView(viewModel: viewModel, hapticEngine: mockHapticEngine)
    }
    .preferredColorScheme(.light)
}

#Preview("Dark/items") {
    let dataManager = DataManager(useCloud: false,
                                  repository: MockDataRepository())
    let preferences = MockAppPreferences()
    let coordinator = AppCoordinator(preferences: preferences)
    let viewModel = ShoppingListViewModel(listID: MockDataRepository.list1ID,
                                          dataManager: dataManager,
                                          coordinator: coordinator)
    let mockHapticEngine = MockHapticEngine()
    
    NavigationStack {
        ShoppingListView(viewModel: viewModel, hapticEngine: mockHapticEngine)
    }
    .preferredColorScheme(.dark)
}

#Preview("Light/empty") {
    let dataManager = DataManager(useCloud: false,
                                  repository: MockDataRepository())
    let preferences = MockAppPreferences()
    let coordinator = AppCoordinator(preferences: preferences)
    let viewModel = ShoppingListViewModel(listID: MockDataRepository.list6ID,
                                          dataManager: dataManager,
                                          coordinator: coordinator)
    let mockHapticEngine = MockHapticEngine()
    
    NavigationStack {
        ShoppingListView(viewModel: viewModel, hapticEngine: mockHapticEngine)
    }
    .preferredColorScheme(.light)
}

#Preview("Dark/empty") {
    let dataManager = DataManager(useCloud: false,
                                  repository: MockDataRepository())
    let preferences = MockAppPreferences()
    let coordinator = AppCoordinator(preferences: preferences)
    let viewModel = ShoppingListViewModel(listID: MockDataRepository.list6ID,
                                          dataManager: dataManager,
                                          coordinator: coordinator)
    let mockHapticEngine = MockHapticEngine()
    
    NavigationStack {
        ShoppingListView(viewModel: viewModel, hapticEngine: mockHapticEngine)
    }
    .preferredColorScheme(.dark)
}
