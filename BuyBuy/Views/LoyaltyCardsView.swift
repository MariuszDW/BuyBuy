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
    
    private static let tileSize: CGFloat = 150

    var body: some View {
        VStack {
            if !viewModel.cards.isEmpty {
                cardsList
            } else {
                emptyView
            }
            
            Spacer()

            bottomPanel
        }
        .navigationTitle(viewModel.cards.isEmpty ? "" : "Loyalty Cards")
        .task {
            await viewModel.loadCards()
        }
    }
    
    private var cardsList: some View {
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
            imageActionMenu
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

    private var bottomPanel: some View {
        HStack {
            Button(action: {
                viewModel.openNewCardDetails()
                print("TODO: Add card")
            }) {
                Label("Add card", systemImage: "plus.circle")
                    .font(.headline)
            }

            Spacer()
        }
        .padding()
        .background(Color.bb.background)
    }
    
    private var imageActionMenu: some View {
        VStack(alignment: .leading, spacing: 32) {
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
                if let index = showActionsForIndex {
                    // TODO: zrobic jakies potwierdzenie usuniecia
                    Task {
                        await viewModel.deleteCard(at: index)
                        showActionsForIndex = nil
                    }
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
