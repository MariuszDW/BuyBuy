//
//  ShoppingListsView.swift
//  BuyBuy
//
//  Created by MDW on 14/05/2025.
//

import SwiftUI

struct ShoppingListsView: View {
    @StateObject var viewModel: ShoppingListsViewModel
    
    @State private var isEditMode: EditMode = .inactive
    @State private var listPendingDeletion: ShoppingList?
    @State private var basketAngle: Double = 0
    @State private var animationTimer: Timer? = nil
    @State private var forceRefreshDiabled = false
    
    init(viewModel: ShoppingListsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if !viewModel.shoppingLists.isEmpty {
                shoppingListsView
                    .environment(\.editMode, $isEditMode)
            } else {
                noContentView(angle: basketAngle)
                    .onAppear {
                        isEditMode = .inactive
                        startBasketAnimation()
                    }
                    .onDisappear {
                        stopBasketAnimation()
                    }
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
            case .dataStorateChanged, .shoppingItemEdited, .shoppingListEdited:
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
                                        Button {
                                            viewModel.openListSettings(for: list)
                                        } label: {
                                            Label("list_settings", systemImage: "square.and.pencil")
                                        }
                                        
                                        Button(role: .destructive) {
                                            Task {
                                                await handleDeleteTapped(for: list)
                                            }
                                        } label: {
                                            Label("delete", systemImage: "trash.fill")
                                        }
                                    }
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    Task {
                                        await handleDeleteTapped(for: list)
                                    }
                                } label: {
                                    Label("delete", systemImage: "trash.fill")
                                }
                            }
                            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                Button {
                                    viewModel.openListSettings(for: list)
                                } label: {
                                    Label("list_settings", systemImage: "square.and.pencil")
                                }
                                .tint(.blue)
                            }
                        }
                    }
                    .listRowInsets(EdgeInsets(top: 6, leading: 6, bottom: 6, trailing: 16))
                }
                .onDelete { offsets in
                    Task {
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
    
    private func listRow(for list: ShoppingList) -> some View {
        HStack {
            list.icon.image
                .symbolRenderingMode(.palette)
                .foregroundStyle(.white, list.color.color)
                .font(.regularDynamic(style: .largeTitle))
                .scaleEffect(1.2)
                .padding(.leading, 8)
                .padding(.trailing, 2)
            
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
                    // .accessibilityLabel("about")
                }
            }
            
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                if isEditMode.isEditing {
                    Button("ok") {
                        withAnimation {
                            isEditMode = .inactive
                        }
                    }
                    // .accessibilityLabel("Done Editing")
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
                    // .accessibilityLabel("Loyalty cards")
                    
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
                        // .accessibilityLabel("Edit")
                        
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
                        // .accessibilityLabel("Settings")
                    } label: {
                        CircleIconView(systemName: "ellipsis")
                    }
                    // .accessibilityLabel("More options")
                }
            }
        }
    }
    
    @ViewBuilder
    private func noContentView(angle: Double) -> some View {
        GeometryReader { geometry in
            Group {
                if geometry.size.isPortrait {
                    VStack() {
                        Spacer()
                        Spacer()
                        noContnetImageView(angle: angle, containerSize: geometry.size)
                        Spacer(minLength: 64)
                        VStack(spacing: 24) {
                            noContnetTitleView()
                            noContnetMessageView()
                        }
                        Spacer()
                        Spacer()
                    }
                } else {
                    HStack {
                        Spacer(minLength: 32)
                        noContnetImageView(angle: angle, containerSize: geometry.size)
                        Spacer(minLength: 56)
                        VStack(alignment: .leading, spacing: 24) {
                            noContnetTitleView(landscape: true)
                            noContnetMessageView(landscape: true)
                        }
                        Spacer(minLength: 32)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .position(x: geometry.size.width * 0.5, y: geometry.size.height * 0.5)
        }
        .padding(.horizontal, 32)
        .padding(.vertical, 40)
    }
    
    func noContnetImageView(angle: Double, containerSize: CGSize) -> some View {
        let listImageSize = min(containerSize.shorterSide * 0.6, containerSize.longerSide * 0.4)
        let basketImageSize = listImageSize * 0.5
        
        return ZStack {
            Image(systemName: "list.bullet.clipboard.fill")
                .resizable()
                .scaledToFit()
                .frame(width: listImageSize, height: listImageSize)
                .foregroundColor(.bb.text.quaternary)
            
            Image(systemName: "basket.fill")
                .resizable()
                .scaledToFit()
                .frame(width: basketImageSize, height: basketImageSize)
                .foregroundColor(.bb.text.quaternary)
                .offset(x: -basketImageSize * 0.5, y: 0)
                .rotationEffect(Angle(degrees: angle), anchor: .topLeading)
                .offset(x: basketImageSize * 0.5, y: 0)
                .offset(x: listImageSize * 0.2, y: listImageSize * 0.38)
                .shadow(color: .black.opacity(0.4), radius: 5)
        }
    }
    
    func noContnetTitleView(landscape: Bool = false) -> some View {
        Text("lists_empty_view_title")
            .font(.boldDynamic(style: .title2))
            .foregroundColor(.bb.text.tertiary)
            .multilineTextAlignment(landscape ? .leading : .center)
    }
    
    func noContnetMessageView(landscape: Bool = false) -> some View {
        Text("lists_empty_view_message")
            .font(.boldDynamic(style: .headline))
            .foregroundColor(.bb.text.tertiary)
            .multilineTextAlignment(landscape ? .leading : .center)
    }
    
    // MARK: - Private
    
    private func forceRefresh() async {
        guard forceRefreshDiabled == false else { return }
        forceRefreshDiabled = true
        await viewModel.loadLists(fullRefresh: true)
        try? await Task.sleep(for: .seconds(1))
        forceRefreshDiabled = false
    }
    
    private func startBasketAnimation() {
        animationTimer?.invalidate()
        animationTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { _ in
            let now = Date().timeIntervalSinceReferenceDate
            let newAngle = sin(now * 3) * 16
            DispatchQueue.main.async {
                basketAngle = newAngle
            }
        }
    }
    
    private func stopBasketAnimation() {
        animationTimer?.invalidate()
        animationTimer = nil
    }
    
    private func handleDeleteTapped(for list: ShoppingList) async {
        Task {
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
                                  coreDataStack: MockCoreDataStack(),
                                  imageStorage: MockImageStorage(),
                                  fileStorage: MockFileStorage(),
                                  repository: MockDataRepository())
    let preferences = MockAppPreferences()
    let tracker = MockUserActivityTracker()
    let coordinator = AppCoordinator(preferences: preferences)
    let mockViewModel = ShoppingListsViewModel(
        dataManager: dataManager,
        userActivityTracker: tracker,
        coordinator: coordinator
    )
    
    NavigationStack {
        ShoppingListsView(viewModel: mockViewModel)
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
    let tracker = MockUserActivityTracker()
    let coordinator = AppCoordinator(preferences: preferences)
    let mockViewModel = ShoppingListsViewModel(
        dataManager: dataManager,
        userActivityTracker: tracker,
        coordinator: coordinator
    )
    
    NavigationStack {
        ShoppingListsView(viewModel: mockViewModel)
    }
    .preferredColorScheme(.dark)
}

#Preview("Light/empty") {
    let dataManager = DataManager(useCloud: false,
                                  coreDataStack: MockCoreDataStack(),
                                  imageStorage: MockImageStorage(),
                                  fileStorage: MockFileStorage(),
                                  repository: MockDataRepository(lists: []))
    let preferences = MockAppPreferences()
    let tracker = MockUserActivityTracker()
    let coordinator = AppCoordinator(preferences: preferences)
    let mockViewModel = ShoppingListsViewModel(
        dataManager: dataManager,
        userActivityTracker: tracker,
        coordinator: coordinator
    )
    
    NavigationStack {
        ShoppingListsView(viewModel: mockViewModel)
    }
    .preferredColorScheme(.light)
}

#Preview("Dark/empty") {
    let dataManager = DataManager(useCloud: false,
                                  coreDataStack: MockCoreDataStack(),
                                  imageStorage: MockImageStorage(),
                                  fileStorage: MockFileStorage(),
                                  repository: MockDataRepository(lists: []))
    let preferences = MockAppPreferences()
    let tracker = MockUserActivityTracker()
    let coordinator = AppCoordinator(preferences: preferences)
    let mockViewModel = ShoppingListsViewModel(
        dataManager: dataManager,
        userActivityTracker: tracker,
        coordinator: coordinator
    )
    
    NavigationStack {
        ShoppingListsView(viewModel: mockViewModel)
    }
    .preferredColorScheme(.dark)
}
