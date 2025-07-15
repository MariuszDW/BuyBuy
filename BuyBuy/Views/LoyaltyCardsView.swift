//
//  LoyaltyCardsView.swift
//  BuyBuy
//
//  Created by MDW on 02/06/2025.
//

import SwiftUI
import Combine

struct LoyaltyCardsView: View {
    @StateObject var viewModel: LoyaltyCardsViewModel
    private var hapticEngine: HapticEngineProtocol
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var showActionsForCardAtIndex: Int? = nil
    @State private var cardPendingDeletion: LoyaltyCard?
    @State private var isEditMode: EditMode = .inactive
    @State private var showingListView: Bool = false
    @State private var forceRefreshDiabled = false
    
    private static let tileSize: CGFloat = 150
    
    init(viewModel: LoyaltyCardsViewModel, hapticEngine: HapticEngineProtocol) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.hapticEngine = hapticEngine
    }

    var body: some View {
        VStack(spacing: 0) {
            if showingListView {
                listView
            } else if !viewModel.cards.isEmpty {
                cardGrids
                    .refreshable {
                        await forceRefresh()
                    }
            } else {
                noContentView
                    .onTapGesture {
                        Task {
                            await forceRefresh()
                        }
                    }
            }
            
            Spacer(minLength: 0)

            BottomPanelView(title: String(localized: "add_card"),
                            systemImage: "plus.circle",
                            isButtonDisabled: isEditMode.isEditing,
                            trailingView: { EmptyView() },
                            action: { viewModel.openNewCardDetails() })
        }
        .alert(item: $cardPendingDeletion) { card in
            return Alert(
                title: Text(String(format: String(localized: "delete_card_title"), card.name)),
                message: Text("delete_card_message"),
                primaryButton: .destructive(Text("delete")) {
                    Task {
                        await viewModel.deleteCard(with: card.id)
                        cardPendingDeletion = nil
                    }
                },
                secondaryButton: .cancel() {
                    cardPendingDeletion = nil
                }
            )
        }
        .onReceive(viewModel.eventPublisher) { event in
            switch event {
            case .loyaltyCardImageChanged:
                Task { await viewModel.loadThumbnails() }
            case .loyaltyCardEdited:
                Task { await viewModel.loadCards() }
            default: break
            }
        }
        .onAppear {
            viewModel.startObserving()
            Task { await viewModel.loadCards() }
            print("LoyaltyCardsView onAppear")
        }
        .onDisappear {
            viewModel.stopObserving()
            print("LoyaltyCardsView onDisappear")
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if isEditMode.isEditing {
                    Button("ok") {
                        withAnimation {
                            isEditMode = .inactive
                            showingListView = false
                        }
                    }
                    // .accessibilityLabel("Done Editing")
                }
                
                if !isEditMode.isEditing && !viewModel.cards.isEmpty {
                    Button {
                        withAnimation {
                            isEditMode = .active
                            showingListView = true
                        }
                    } label: {
                        Label("edit_list", systemImage: "pencil.circle")
                    }
                    // .accessibilityLabel("Edit")
                }
            }
        }
        .navigationTitle(viewModel.cards.isEmpty ? "" : "loyalty_cards")
        .task {
            await viewModel.loadCards()
        }
    }
    
    private var listView: some View {
        List {
            ForEach(viewModel.cards) { card in
                HStack {
                    if let thumbnail = viewModel.thumbnail(for: card.id) {
                        Image(uiImage: thumbnail)
                            .resizable()
                            .frame(width: 40, height: 40)
                            .cornerRadius(4)
                    } else {
                        Image(systemName: "creditcard.fill")
                            .resizable()
                            .scaledToFit()
                            .padding(6)
                            .frame(width: 40, height: 40)
                            .foregroundColor(.bb.text.quaternary)
                            .background(Color.bb.background2)
                            .cornerRadius(4)
                    }
                    Text(card.name)
                        .foregroundColor(.bb.text.primary)
                        .font(.regularDynamic(style: .headline))
                        .multilineTextAlignment(.leading)
                        .lineLimit(5)
                }
            }
            .onMove { indices, newOffset in
                Task {
                    await viewModel.moveCard(from: indices, to: newOffset)
                }
            }
            .onDelete { indexSet in
                Task {
                    hapticEngine.playItemDeleted()
                    await viewModel.deleteCards(at: indexSet)
                }
            }
        }
        .environment(\.editMode, $isEditMode)
    }
    
    private var cardGrids: some View {
        let tileSpacingH: CGFloat = horizontalSizeClass == .regular ? 24 : 12
        let tileSpacingV: CGFloat = 24
        let tileWidth: CGFloat = 150

        let columns = [
            GridItem(.adaptive(minimum: tileWidth), spacing: tileSpacingH, alignment: .top)
        ]

        return ScrollView {
            LazyVGrid(columns: columns, spacing: tileSpacingV) {
                ForEach(Array(viewModel.cards.enumerated()), id: \.element.id) { index, card in
                    tileView(for: card, index: index)
                }
            }
            .padding(.horizontal, horizontalSizeClass == .regular ? 32 : 16)
            .padding(.vertical, 16)
        }
    }
    
    @ViewBuilder
    private func tileView(for card: LoyaltyCard, index: Int) -> some View {
        LoyaltyCardTileView(
            id: card.id,
            name: card.name,
            thumbnail: viewModel.thumbnail(for: card.id),
            tileWidth: Self.tileSize,
            selected: showActionsForCardAtIndex == index
        )
        .frame(width: Self.tileSize, alignment: .top)
        .onTapGesture {
            viewModel.openCardPreview(card)
        }
        .onLongPressGesture {
            hapticEngine.playSelectionChanged()
            showActionsForCardAtIndex = index
        }
        .popover(isPresented: Binding(
            get: {
                showActionsForCardAtIndex == index
            },
            set: { newValue in
                if !newValue {
                    showActionsForCardAtIndex = nil
                }
            })
        ) {
            cardActionMenu
                .presentationCompactAdaptation(.popover)
        }
    }
    
    private var noContentView: some View {
        NoContnetView(title: String(localized: "card_empty_view_title"),
                      message: String(localized: "card_empty_view_message"),
                      image: Image(systemName: "creditcard.fill"),
                      color: .bb.text.tertiary)
    }

    private var cardActionMenu: some View {
        VStack(alignment: .leading, spacing: 24) {
            Button {
                if let index = showActionsForCardAtIndex {
                    showActionsForCardAtIndex = nil
                    viewModel.openCardPreview(at: index)
                }
            } label: {
                HStack {
                    Text("view_image")
                    Spacer()
                    Image(systemName: "eye")
                }
                .foregroundColor(.bb.selection)
            }
            
            Button {
                if let index = showActionsForCardAtIndex {
                    showActionsForCardAtIndex = nil
                    viewModel.openCardDetails(at: index)
                }
            } label: {
                HStack {
                    Text("edit")
                    Spacer()
                    Image(systemName: "square.and.pencil")
                }
                .foregroundColor(.bb.selection)
            }
            
            Button {
                if let index = showActionsForCardAtIndex, index < viewModel.cards.count {
                    hapticEngine.playItemDeleted()
                    showActionsForCardAtIndex = nil
                    Task { @MainActor in
                        try? await Task.sleep(for: .microseconds(500))
                        cardPendingDeletion = viewModel.cards[index]
                    }
                }
            } label: {
                HStack {
                    Text("delete")
                    Spacer()
                    Image(systemName: "trash")
                }
                .foregroundColor(.bb.destructive)
            }
        }
        .padding()
    }
    
    private func forceRefresh() async {
        guard forceRefreshDiabled == false else { return }
        forceRefreshDiabled = true
        await viewModel.loadCards(fullRefresh: true)
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
    let mockViewModel = LoyaltyCardsViewModel(
        dataManager: dataManager,
        coordinator: coordinator
    )
    let mockHapticEngine = MockHapticEngine()
    
    NavigationStack {
        LoyaltyCardsView(viewModel: mockViewModel, hapticEngine: mockHapticEngine)
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
    let mockViewModel = LoyaltyCardsViewModel(
        dataManager: dataManager,
        coordinator: coordinator
    )
    let mockHapticEngine = MockHapticEngine()
    
    NavigationStack {
        LoyaltyCardsView(viewModel: mockViewModel, hapticEngine: mockHapticEngine)
    }
    .preferredColorScheme(.dark)
}

#Preview("Light/empty") {
    let dataManager = DataManager(useCloud: false,
                                  coreDataStack: MockCoreDataStack(),
                                  imageStorage: MockImageStorage(),
                                  fileStorage: MockFileStorage(),
                                  repository: MockDataRepository(lists: [], cards: []))
    let preferences = MockAppPreferences()
    let coordinator = AppCoordinator(preferences: preferences)
    let mockViewModel = LoyaltyCardsViewModel(
        dataManager: dataManager,
        coordinator: coordinator
    )
    let mockHapticEngine = MockHapticEngine()
    
    NavigationStack {
        LoyaltyCardsView(viewModel: mockViewModel, hapticEngine: mockHapticEngine)
    }
    .preferredColorScheme(.light)
}

#Preview("Dark/empty") {
    let dataManager = DataManager(useCloud: false,
                                  coreDataStack: MockCoreDataStack(),
                                  imageStorage: MockImageStorage(),
                                  fileStorage: MockFileStorage(),
                                  repository: MockDataRepository(lists: [], cards: []))
    let preferences = MockAppPreferences()
    let coordinator = AppCoordinator(preferences: preferences)
    let mockViewModel = LoyaltyCardsViewModel(
        dataManager: dataManager,
        coordinator: coordinator
    )
    let mockHapticEngine = MockHapticEngine()
    
    NavigationStack {
        LoyaltyCardsView(viewModel: mockViewModel, hapticEngine: mockHapticEngine)
    }
    .preferredColorScheme(.dark)
}
