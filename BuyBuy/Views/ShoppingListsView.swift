//
//  ShoppingListsView.swift
//  BuyBuy
//
//  Created by MDW on 14/05/2025.
//

import SwiftUI

struct ShoppingListsView: View {
    @StateObject var viewModel: ShoppingListsViewModel
    private let hapticEngine: HapticEngineProtocol
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    @State private var isEditMode: EditMode = .inactive
    @State private var listPendingDeletion: ShoppingList?
    @State private var forceRefreshDiabled = false
    
    init(viewModel: ShoppingListsViewModel, hapticEngine: HapticEngineProtocol) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.hapticEngine = hapticEngine
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if !viewModel.shoppingLists.isEmpty {
                shoppingListsView
                    .environment(\.editMode, $isEditMode)
            } else {
                noContentView
                    .onTapGesture {
                        Task {
                            await forceRefresh()
                        }
                    }
            }
            
            Spacer(minLength: 0)
            
            BottomPanelView(title: String(localized: "add_list"),
                            systemImage: "plus.circle",
                            isButtonDisabled: isEditMode.isEditing,
                            trailingView: { EmptyView() },
                            action: { viewModel.openNewListSettings() })
        }
        .navigationTitle(viewModel.shoppingLists.isEmpty ? "" : "shopping_lists")
        .navigationBarTitleDisplayMode(.large)
        .onChange(of: viewModel.shoppingLists) { newValue in
            if newValue.isEmpty {
                isEditMode = .inactive
            }
        }
        .toolbar {
            toolbarContent
        }
        .alert(item: $listPendingDeletion) { list in
            Alert(
                title: Text(String(format: String(localized: "delete_list_title"), list.name)),
                message: Text("delete_list_message"),
                primaryButton: .destructive(Text("delete")) {
                    Task {
                        await viewModel.deleteList(id: list.id)
                        listPendingDeletion = nil
                    }
                },
                secondaryButton: .cancel() {
                    listPendingDeletion = nil
                }
            )
        }
        .onAppear {
            viewModel.startObserving()
            Task { await viewModel.loadLists() }
        }
        .onDisappear() {
            viewModel.stopObserving()
        }
        .onReceive(viewModel.coordinator.eventPublisher) { event in
            switch event {
            case .dataStorageChanged, .shoppingItemEdited, .shoppingListEdited:
                Task { await viewModel.loadLists() }
            default: break
            }
        }
    }
    
    // MARK: - Subviews
    
    private var shoppingListsView: some View {
        List {
            Section() {
                ForEach(viewModel.shoppingLists.filter { $0.id != listPendingDeletion?.id }) { list in
                    Group {
                        if isEditMode.isEditing {
                            listRow(for: list)
                        } else {
                            NavigationLink(value: AppRoute.shoppingList(list.id)) {
                                listRow(for: list)
                                    .contextMenu {
                                        contextMenu(for: list)
                                    }
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                trailingSwipeActions(for: list)
                            }
                            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                leadingSwipeActions(for: list)
                            }
                        }
                    }
                    .listRowInsets(EdgeInsets(top: 6, leading: 6, bottom: 6, trailing: 16))
                }
                .onDelete { offsets in
                    Task {
                        hapticEngine.playItemDeleted()
                        await viewModel.deleteLists(atOffsets: offsets)
                    }
                }
                .onMove { indices, newOffset in
                    Task {
                        await viewModel.moveLists(fromOffsets: indices, toOffset: newOffset)
                    }
                }
            }
        }
        .listStyle(.plain)
        .refreshable {
            await forceRefresh()
        }
    }
    
    @ViewBuilder
    private func contextMenu(for list: ShoppingList) -> some View {
        Button {
            viewModel.openListSettings(for: list)
        } label: {
            Label("list_settings", systemImage: "list.clipboard.fill")
        }
        
        if viewModel.isCloud {
            Button {
                Task {
                    await viewModel.openShareManagement(for: list)
                }
            } label: {
                Label("colaboration", systemImage: "person.2.fill")
            }
        }
        
        Button(role: .destructive) {
            Task {
                await handleDeleteTapped(for: list)
            }
        } label: {
            Label("delete", systemImage: "trash.fill")
        }
    }
    
    @ViewBuilder
    private func trailingSwipeActions(for list: ShoppingList) -> some View {
        Button(role: .destructive) {
            Task {
                await handleDeleteTapped(for: list)
            }
        } label: {
            Label("delete", systemImage: "trash.fill")
        }
    }

    @ViewBuilder
    private func leadingSwipeActions(for list: ShoppingList) -> some View {
        Button {
            viewModel.openListSettings(for: list)
        } label: {
            Label("list_settings", systemImage: "list.clipboard.fill")
        }
        .tint(.blue)
        
        if viewModel.isCloud {
            Button {
                Task {
                    await viewModel.openShareManagement(for: list)
                }
            } label: {
                Label("colaboration", systemImage: "person.2.fill")
            }
        }
    }
    
    private func listRow(for list: ShoppingList) -> some View {
        HStack {
            list.icon.image
                .symbolRenderingMode(.palette)
                .foregroundStyle(.white, list.color.color)
                .font(.regularDynamic(style: .largeTitle))
                .scaleEffect(1.2)
                .padding(.leading, horizontalSizeClass == .regular ? 24 : 8)
                .padding(.trailing, horizontalSizeClass == .regular ? 2 : 4)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(list.name)
                    .foregroundColor(.bb.text.primary)
                    .font(.regularDynamic(style: .title3))
                    .multilineTextAlignment(.leading)
                    .lineLimit(4)
                
                HStack {
                    ShoppingItemStatus.pending.image
                        .font(.regularDynamic(style: .callout))
                        .foregroundColor(ShoppingItemStatus.pending.color)
                    Text("\(list.items(for: .pending).count)")
                        .foregroundColor(ShoppingItemStatus.pending.color)
                        .font(.regularDynamic(style: .callout))
                    
                    ShoppingItemStatus.purchased.image
                        .font(.regularDynamic(style: .callout))
                        .foregroundColor(ShoppingItemStatus.purchased.color)
                        .padding(.leading, 16)
                    Text("\(list.items(for: .purchased).count)")
                        .foregroundColor(ShoppingItemStatus.purchased.color)
                        .font(.regularDynamic(style: .callout))
                    
                    ShoppingItemStatus.inactive.image
                        .font(.regularDynamic(style: .callout))
                        .foregroundColor(ShoppingItemStatus.inactive.color)
                        .padding(.leading, 16)
                    Text("\(list.items(for: .inactive).count)")
                        .foregroundColor(ShoppingItemStatus.inactive.color)
                        .font(.regularDynamic(style: .callout))
                }
            }
            .padding(.leading, 4)
        }
        .padding(.vertical, 4)
    }
    
    private var toolbarContent: some ToolbarContent {
        Group {
            ToolbarItem(placement: .navigationBarLeading) {
                if !isEditMode.isEditing {
                    Button {
                        viewModel.openAbout()
                    } label: {
                        CircleIconView(systemName: "questionmark")
                    }
                }
            }
            
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                if isEditMode.isEditing {
                    Button("ok") {
                        withAnimation {
                            isEditMode = .inactive
                        }
                    }
                }
                
                if !isEditMode.isEditing {
                    if viewModel.shouldShowTipJarButton {
                        Button {
                            viewModel.openTipJar()
                        } label: {
                            CircleIconView(systemName: "cup.and.saucer.fill")
                        }
                    }
                    
                    Button {
                        viewModel.openLoyaltyCards()
                    } label: {
                        CircleIconView(systemName: "creditcard.fill")
                    }
                    
                    Menu {
                        Button {
                            withAnimation {
                                isEditMode = .active
                            }
                        } label: {
                            Label("edit_list", systemImage: "pencil")
                                .lineLimit(1)
                        }
                        .disabled(viewModel.shoppingLists.isEmpty)
                        
                        Button {
                            viewModel.openDeletedItems()
                        } label: {
                            Label("recently_deleted", systemImage: "trash")
                                .lineLimit(1)
                        }
                        .disabled(isEditMode.isEditing)
                        
                        Button {
                            isEditMode = .inactive
                            viewModel.openSettings()
                        } label: {
                            Label("settings", systemImage: "gearshape")
                                .lineLimit(1)
                        }
                    } label: {
                        CircleIconView(systemName: "ellipsis")
                    }
                }
            }
        }
    }
    
    private var noContentView: some View {
        NoContnetView(title: String(localized: "lists_empty_view_title"),
                      message: String(localized: "lists_empty_view_message"),
                      image: Image(systemName: "list.bullet.clipboard.fill"),
                      color: .bb.text.tertiary)
    }
    
    // MARK: - Private
    
    private func forceRefresh() async {
        guard forceRefreshDiabled == false else { return }
        forceRefreshDiabled = true
        await viewModel.loadLists(fullRefresh: true)
        try? await Task.sleep(for: .seconds(1))
        forceRefreshDiabled = false
    }
    
    private func handleDeleteTapped(for list: ShoppingList) async {
        Task {
            hapticEngine.playItemDeleted()
            if list.items.isEmpty {
                await viewModel.deleteList(id: list.id)
            } else {
                listPendingDeletion = list
            }
        }
    }
}

// MARK: - Preview

#Preview("Light/items") {
    let dataManager = DataManager(useCloud: false,
                                  repository: MockDataRepository())
    let preferences = MockAppPreferences()
    let tracker = MockUserActivityTracker()
    let coordinator = AppCoordinator(preferences: preferences)
    let mockViewModel = ShoppingListsViewModel(
        dataManager: dataManager,
        userActivityTracker: tracker,
        coordinator: coordinator
    )
    let mockHapticEngine = MockHapticEngine()
    
    NavigationStack {
        ShoppingListsView(viewModel: mockViewModel, hapticEngine: mockHapticEngine)
    }
    .preferredColorScheme(.light)
}

#Preview("Dark/items") {
    let dataManager = DataManager(useCloud: false,
                                  repository: MockDataRepository())
    let preferences = MockAppPreferences()
    let tracker = MockUserActivityTracker()
    let coordinator = AppCoordinator(preferences: preferences)
    let mockViewModel = ShoppingListsViewModel(
        dataManager: dataManager,
        userActivityTracker: tracker,
        coordinator: coordinator
    )
    let mockHapticEngine = MockHapticEngine()
    
    NavigationStack {
        ShoppingListsView(viewModel: mockViewModel, hapticEngine: mockHapticEngine)
    }
    .preferredColorScheme(.dark)
}

#Preview("Light/empty") {
    let dataManager = DataManager(useCloud: false,
                                  repository: MockDataRepository(lists: []))
    let preferences = MockAppPreferences()
    let tracker = MockUserActivityTracker()
    let coordinator = AppCoordinator(preferences: preferences)
    let mockViewModel = ShoppingListsViewModel(
        dataManager: dataManager,
        userActivityTracker: tracker,
        coordinator: coordinator
    )
    let mockHapticEngine = MockHapticEngine()
    
    NavigationStack {
        ShoppingListsView(viewModel: mockViewModel, hapticEngine: mockHapticEngine)
    }
    .preferredColorScheme(.light)
}

#Preview("Dark/empty") {
    let dataManager = DataManager(useCloud: false,
                                  repository: MockDataRepository(lists: []))
    let preferences = MockAppPreferences()
    let tracker = MockUserActivityTracker()
    let coordinator = AppCoordinator(preferences: preferences)
    let mockViewModel = ShoppingListsViewModel(
        dataManager: dataManager,
        userActivityTracker: tracker,
        coordinator: coordinator
    )
    let mockHapticEngine = MockHapticEngine()
    
    NavigationStack {
        ShoppingListsView(viewModel: mockViewModel, hapticEngine: mockHapticEngine)
    }
    .preferredColorScheme(.dark)
}
