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
    
    init(viewModel: ShoppingListViewModel, hapticEngine: HapticEngineProtocol) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.hapticEngine = hapticEngine
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if let list = viewModel.list, !list.items.isEmpty {
                sections(list)
                    .environment(\.editMode, $isEditMode)
                    .listStyle(.grouped)
            } else {
                noContentView
                    .onAppear {
                        isEditMode = .inactive
                    }
                    .onTapGesture {
                        Task {
                            await forceRefresh()
                        }
                    }
            }
            
            Spacer(minLength: 0)
            
            BottomPanelView(title: String(localized: "add_item"),
                            systemImage: "plus.circle",
                            isButtonDisabled: isEditMode.isEditing,
                            trailingView: { summaryView() },
                            action: {
                if let listID = viewModel.list?.id {
                    viewModel.openNewItemDetails(listID: listID)
                }
            })
        }
        .toolbar {
            toolbarContent
        }
        .navigationTitle(viewModel.list?.name ?? "")
        .navigationBarTitleDisplayMode(.large)
        .onReceive(viewModel.eventPublisher) { event in
            switch event {
            case .shoppingItemImageChanged, .shoppingItemEdited:
                Task { await viewModel.loadList() }
            default: break
            }
        }
        .onAppear {
            viewModel.startObserving()
        }
        .onDisappear {
            viewModel.stopObserving()
        }
        .task {
            await viewModel.loadList()
        }
        .alert("delete_purchased_items_title",
               isPresented: $showDeletePurchasedAlert) {
            Button("delete", role: .destructive) {
                Task {
                    await viewModel.deletePurchasedItems()
                }
            }
            Button("cancel", role: .cancel) { }
        } message: {
            Text("delete_purchased_items_message")
        }
    }
    
    @ViewBuilder
    private func sections(_ list: ShoppingList) -> some View {
        List {
            ForEach(viewModel.sections, id: \.status) { section in
                let items = list.items(for: section.status)
                if !items.isEmpty {
                    Section(header: sectionHeader(section: section, sectionItemCount: items.count)) {
                        shoppingItems(items, of: section)
                    }
                }
            }
        }
        .animation(.default, value: list.items)
        .refreshable {
            await forceRefresh()
        }
    }
    
    @ViewBuilder
    private func shoppingItems(_ items: [ShoppingItem], of section: ShoppingListSection) -> some View {
        if !section.isCollapsed {
            ForEach(items) { item in
                itemView(item: item, section: section)
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
    }
    
    private func itemView(item: ShoppingItem, section: ShoppingListSection) -> some View {
        return ShoppingItemRow(
            item: item,
            thumbnail: viewModel.thumbnail(for: item.imageIDs.first),
            state: isEditMode == .inactive,
            onToggleStatus: { toggledItemID in
                hapticEngine.playItemChecked()
                viewModel.toggleStatus(for: toggledItemID)
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
                    await handleDeleteTapped(for: item)
                }
            } label: {
                Label("delete", systemImage: "trash.fill")
            }
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive) {
                Task {
                    await handleDeleteTapped(for: item)
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
            ForEach(ShoppingItemStatus.allCases, id: \.self) { (status: ShoppingItemStatus) in
                if item.status != status {
                    Button {
                        Task {
                            hapticEngine.playItemChecked()
                            await viewModel.setStatus(status, itemID: item.id)
                        }
                    } label: {
                        Label(status.rawValue, systemImage: status.imageSystemName)
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
                    // .accessibilityLabel("Loyalty cards")
                }
                
                if isEditMode.isEditing {
                    Button("ok") {
                        withAnimation {
                            isEditMode = .inactive
                        }
                    }
                    // .accessibilityLabel("Done Editing")
                }
                
                if !isEditMode.isEditing {
                    Menu {
                        Button {
                            withAnimation {
                                isEditMode = .active
                            }
                        } label: {
                            Label("edit_list", systemImage: "pencil")
                        }
                        // .accessibilityLabel("Edit")
                        
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
                    .disabled(viewModel.list?.items.isEmpty ?? true)
                    // .accessibilityLabel("More options")
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
    private func sectionHeader(section: ShoppingListSection, sectionItemCount: Int) -> some View {
        let title: String = section.isCollapsed ? section.localizedTitle + " (\(sectionItemCount))" : section.localizedTitle
        
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
    
    @ViewBuilder
    private func summaryView() -> some View {
        let numPendingItems = viewModel.list?.items(for: .pending).count ?? 0
        let numPurchasedItems = viewModel.list?.items(for: .purchased).count ?? 0
        let totalPriceOfPendingItems = viewModel.list?.totalPrice(for: .pending) ?? 0
        let totalPriceOfPurchasedItems = viewModel.list?.totalPrice(for: .purchased) ?? 0
        let showItemPrices = viewModel.list?.containsItemsWithPrice() ?? false
        
        let pendingItemsIcon = ShoppingItemStatus.pending.image
            .font(.boldDynamic(style: .body))
            .lineLimit(1)
            .foregroundColor(ShoppingItemStatus.pending.color)
        
        let purchasedItemsIcon = ShoppingItemStatus.purchased.image
            .font(.boldDynamic(style: .body))
            .lineLimit(1)
            .foregroundColor(ShoppingItemStatus.purchased.color)
        
        let pendingItemsText = Text("\(numPendingItems)")
            .font(.boldMonospaced(style: .body))
            .lineLimit(1)
            .foregroundColor(ShoppingItemStatus.pending.color)
        
        let purchasedItemsText = Text("\(numPurchasedItems)")
            .font(.boldMonospaced(style: .body))
            .lineLimit(1)
            .foregroundColor(ShoppingItemStatus.purchased.color)
        
        HStack(alignment: .center, spacing: 12) {
            if showItemPrices {
                VStack(alignment: .trailing, spacing: 2) {
                    pendingItemsIcon
                    purchasedItemsIcon
                }
                
                VStack(alignment: .trailing, spacing: 2) {
                    pendingItemsText
                    purchasedItemsText
                }
                
                Rectangle()
                    .foregroundColor(.bb.text.quaternary)
                    .frame(width: 2)
                    .frame(maxHeight: .infinity)
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text(totalPriceOfPendingItems.priceFormat)
                        .font(.boldMonospaced(style: .body))
                        .foregroundColor(ShoppingItemStatus.pending.color)
                    
                    Text(totalPriceOfPurchasedItems.priceFormat)
                        .font(.boldMonospaced(style: .body))
                        .foregroundColor(ShoppingItemStatus.purchased.color)
                }
            } else {
                HStack(spacing: 6) {
                    pendingItemsIcon
                    pendingItemsText
                }
                .padding(.trailing, 12)
                
                HStack(spacing: 6) {
                    purchasedItemsIcon
                    purchasedItemsText
                }
            }
        }
        .padding(.trailing, 8)
        .fixedSize(horizontal: false, vertical: true)
        .layoutPriority(1)
    }
    
    // MARK: - Private
    
    private func handleDeleteTapped(for item: ShoppingItem) async {
        hapticEngine.playItemDeleted()
        await viewModel.moveItemToDeleted(with: item.id)
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
                                  coreDataStack: MockCoreDataStack(),
                                  imageStorage: MockImageStorage(),
                                  fileStorage: MockFileStorage(),
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
                                  coreDataStack: MockCoreDataStack(),
                                  imageStorage: MockImageStorage(),
                                  fileStorage: MockFileStorage(),
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
                                  coreDataStack: MockCoreDataStack(),
                                  imageStorage: MockImageStorage(),
                                  fileStorage: MockFileStorage(),
                                  repository: MockDataRepository())
    let preferences = MockAppPreferences()
    let coordinator = AppCoordinator(preferences: preferences)
    let viewModel = ShoppingListViewModel(listID: MockDataRepository.list5ID,
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
                                  coreDataStack: MockCoreDataStack(),
                                  imageStorage: MockImageStorage(),
                                  fileStorage: MockFileStorage(),
                                  repository: MockDataRepository())
    let preferences = MockAppPreferences()
    let coordinator = AppCoordinator(preferences: preferences)
    let viewModel = ShoppingListViewModel(listID: MockDataRepository.list5ID,
                                          dataManager: dataManager,
                                          coordinator: coordinator)
    let mockHapticEngine = MockHapticEngine()
    
    NavigationStack {
        ShoppingListView(viewModel: viewModel, hapticEngine: mockHapticEngine)
    }
    .preferredColorScheme(.dark)
}
