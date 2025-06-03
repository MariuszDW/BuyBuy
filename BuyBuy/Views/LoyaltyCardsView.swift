//
//  LoyaltyCardsView.swift
//  BuyBuy
//
//  Created by MDW on 02/06/2025.
//

import SwiftUI

struct LoyaltyCardsView: View {
    @StateObject var viewModel: LoyaltyCardsViewModel

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
        .onAppear { // TODO: moze task?
            Task {
                await viewModel.loadCards()
            }
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
                ForEach(viewModel.cards) { card in
                    LoyaltyCardTileView(
                        id: card.id,
                        name: card.name,
                        thumbnail: viewModel.thumbnail(for: card.id),
                        tileWidth: tileWidth
                    )
                    .frame(width: tileWidth, alignment: .top)
                    .onTapGesture {
                        viewModel.openCardPreview(card)
                    }
                }
            }
            .padding(16)
        }
    }
    
    private var emptyView: some View {
        GeometryReader { geometry in
            let baseSize = min(geometry.size.width, geometry.size.height)
            
            VStack(spacing: 50) {
                AnimatedIconView(
                    image: Image(systemName: "creditcard.fill"),
                    color: .bb.grey85,
                    size: baseSize * 0.5,
                    response: 0.8,
                    dampingFraction: 0.3
                )
                
                Text("No loyalty cards yet.")
                    .font(.boldDynamic(style: .title2))
                    .foregroundColor(.bb.grey75)
                    .multilineTextAlignment(.center)
                
                Text("Use the 'Add card' button to add your first layalty card.")
                    .font(.boldDynamic(style: .headline))
                    .foregroundColor(.bb.grey75)
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
