//
//  LoyaltyCardsView.swift
//  BuyBuy
//
//  Created by MDW on 02/06/2025.
//

import SwiftUI

struct LoyaltyCardsView: View {
    @StateObject var viewModel: LoyaltyCardsViewModel
    @State private var showActionsForIndex: Int? = nil
    @State private var cardPendingDeletion: LoyaltyCard?
    @State private var isEditMode: EditMode = .inactive
    @State private var showingListView: Bool = false
    
    private static let tileSize: CGFloat = 150

    var body: some View {
        VStack(spacing: 0) {
            if showingListView {
                listView
            } else if !viewModel.cards.isEmpty {
                cardGrids
            } else {
                emptyView
            }
            
            Spacer(minLength: 0)

            BottomPanelView(title: "Add card",
                            systemImage: "plus.circle",
                            isButtonDisabled: isEditMode.isEditing,
                            trailingView: { EmptyView() },
                            action: { viewModel.openNewCardDetails() })
        }
        .alert(item: $cardPendingDeletion) { card in
            return Alert(
                title: Text("Delete loyalty card \"\(card.name)\"?"),
                message: Text("Are you sure you want to delete it?"),
                primaryButton: .destructive(Text("Delete")) {
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
        .onReceive(viewModel.coordinator.eventPublisher) { event in
            if case .loyaltyCardEdited = event {
                Task {
                    await viewModel.loadCards()
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if isEditMode.isEditing {
                    Button("OK") {
                        withAnimation {
                            isEditMode = .inactive
                            showingListView = false
                        }
                    }
                    .accessibilityLabel("Done Editing")
                }
                
                if !isEditMode.isEditing && !viewModel.cards.isEmpty {
                    Button {
                        withAnimation {
                            isEditMode = .active
                            showingListView = true
                        }
                    } label: {
                        Label("Edit list", systemImage: "pencil.circle")
                    }
                    .accessibilityLabel("Edit")
                }
            }
        }
        .navigationTitle(viewModel.cards.isEmpty ? "" : "Loyalty Cards")
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
                    await viewModel.deleteCards(at: indexSet)
                }
            }
        }
        .environment(\.editMode, $isEditMode)
    }
    
    private var cardGrids: some View {
        let tileSpacing: CGFloat = 12
        let tileWidth: CGFloat = 150

        let columns = [
            GridItem(.adaptive(minimum: tileWidth), spacing: tileSpacing, alignment: .top)
        ]

        return ScrollView {
            LazyVGrid(columns: columns, spacing: tileSpacing * 2) {
                ForEach(Array(viewModel.cards.enumerated()), id: \.element.id) { index, card in
                    tileView(for: card, index: index)
                }
            }
            .padding(16)
        }
    }
    
    @ViewBuilder
    private func tileView(for card: LoyaltyCard, index: Int) -> some View {
        LoyaltyCardTileView(
            id: card.id,
            name: card.name,
            thumbnail: viewModel.thumbnail(for: card.id),
            tileWidth: Self.tileSize,
            selected: showActionsForIndex == index
        )
        .frame(width: Self.tileSize, alignment: .top)
        .onTapGesture {
            viewModel.openCardPreview(card)
        }
        .onLongPressGesture {
            showActionsForIndex = index
        }
        .popover(isPresented: Binding(
            get: {
                showActionsForIndex == index
            },
            set: { newValue in
                if !newValue {
                    showActionsForIndex = nil
                }
            })
        ) {
            cardActionMenu
                .presentationCompactAdaptation(.popover)
        }
    }
    
    private var emptyView: some View {
        GeometryReader { geometry in
            let baseSize = min(geometry.size.width, geometry.size.height)
            
            VStack(spacing: 50) {
                AnimatedIconView(
                    image: Image(systemName: "creditcard.fill"),
                    color: .bb.text.quaternary,
                    size: baseSize * 0.5,
                    response: 0.8,
                    dampingFraction: 0.3
                )
                
                Text("No loyalty cards yet.")
                    .font(.boldDynamic(style: .title2))
                    .foregroundColor(.bb.text.tertiary)
                    .multilineTextAlignment(.center)
                
                Text("Use the 'Add card' button to add your first layalty card.")
                    .font(.boldDynamic(style: .headline))
                    .foregroundColor(.bb.text.tertiary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .position(x: geometry.size.width * 0.5, y: geometry.size.height * 0.5)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 40)
    }

    private var cardActionMenu: some View {
        VStack(alignment: .leading, spacing: 24) {
            Button {
                if let index = showActionsForIndex {
                    viewModel.openCardPreview(at: index)
                    showActionsForIndex = nil
                }
            } label: {
                HStack {
                    Text("Show")
                    Spacer()
                    Image(systemName: "eye")
                }
                .foregroundColor(.bb.selection)
            }
            
            Button {
                if let index = showActionsForIndex {
                    viewModel.openCardDetails(at: index)
                    showActionsForIndex = nil
                }
            } label: {
                HStack {
                    Text("Edit")
                    Spacer()
                    Image(systemName: "square.and.pencil")
                }
                .foregroundColor(.bb.selection)
            }
            
            Button {
                if let index = showActionsForIndex, index < viewModel.cards.count {
                    cardPendingDeletion = viewModel.cards[index]
                    showActionsForIndex = nil
                }
            } label: {
                HStack {
                    Text("Delete")
                    Spacer()
                    Image(systemName: "trash")
                }
                .foregroundColor(.bb.destructive)
            }
        }
        .padding()
    }
}

// MARK: - Preview

#Preview("Light/items") {
    let dataManager = DataManager(repository: MockDataRepository(),
                                  imageStorage: MockImageStorage())
    let mockViewModel = LoyaltyCardsViewModel(
        dataManager: dataManager,
        coordinator: AppCoordinator(dependencies: AppDependencies())
    )
    
    NavigationStack {
        LoyaltyCardsView(viewModel: mockViewModel)
    }
    .preferredColorScheme(.light)
}

#Preview("Dark/items") {
    let dataManager = DataManager(repository: MockDataRepository(),
                                  imageStorage: MockImageStorage())
    let mockViewModel = LoyaltyCardsViewModel(
        dataManager: dataManager,
        coordinator: AppCoordinator(dependencies: AppDependencies())
    )
    
    NavigationStack {
        LoyaltyCardsView(viewModel: mockViewModel)
    }
    .preferredColorScheme(.dark)
}

#Preview("Light/empty") {
    let dataManager = DataManager(repository: MockDataRepository(lists: [], cards: []),
                                  imageStorage: MockImageStorage())
    let mockViewModel = LoyaltyCardsViewModel(
        dataManager: dataManager,
        coordinator: AppCoordinator(dependencies: AppDependencies())
    )
    
    NavigationStack {
        LoyaltyCardsView(viewModel: mockViewModel)
    }
    .preferredColorScheme(.light)
}

#Preview("Dark/empty") {
    let dataManager = DataManager(repository: MockDataRepository(lists: [], cards: []),
                                  imageStorage: MockImageStorage())
    let mockViewModel = LoyaltyCardsViewModel(
        dataManager: dataManager,
        coordinator: AppCoordinator(dependencies: AppDependencies())
    )
    
    NavigationStack {
        LoyaltyCardsView(viewModel: mockViewModel)
    }
    .preferredColorScheme(.dark)
}
