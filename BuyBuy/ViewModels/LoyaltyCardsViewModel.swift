//
//  LoyaltyCardsViewModel.swift
//  BuyBuy
//
//  Created by MDW on 02/06/2025.
//

import Foundation
import SwiftUI

@MainActor
final class LoyaltyCardsViewModel: ObservableObject {
    @Published var cards: [LoyaltyCard] = []
    @Published private(set) var thumbnails: [UUID: UIImage] = [:]
    
    private let dataManager: DataManagerProtocol
    let coordinator: any AppCoordinatorProtocol
    
    init(dataManager: DataManagerProtocol, coordinator: any AppCoordinatorProtocol) {
        self.dataManager = dataManager
        self.coordinator = coordinator
    }
    
    func loadCards() async {
        let fetchedCards = try? await dataManager.fetchLoyaltyCards()
        cards = fetchedCards ?? []
        await loadThumbnails()
    }

    func thumbnail(for cardID: UUID) -> UIImage? {
        thumbnails[cardID]
    }
    
    func moveCard(from source: IndexSet, to destination: Int) async {
        var updatedCards = cards
        updatedCards.move(fromOffsets: source, toOffset: destination)

        let reorderedCards = updatedCards.enumerated().map { index, card in
            var updatedCard = card
            updatedCard.order = index
            return updatedCard
        }

        for card in reorderedCards {
            try? await dataManager.addOrUpdateLoyaltyCard(card)
        }

        await loadCards()
    }

    func openCardPreview(_ card: LoyaltyCard) {
        coordinator.openLoyaltyCardPreview(with: card.imageID, onDismiss: nil)
    }
    
    func openCardPreview(at index: Int) {
        if index < cards.count {
            coordinator.openLoyaltyCardPreview(with: cards[index].imageID, onDismiss: nil)
        }
    }
    
    func deleteCard(with id: UUID) async {
        try? await dataManager.deleteLoyaltyCard(with: id)
        await loadCards()
    }
    
    func deleteCards(at indexSet: IndexSet) async {
        for index in indexSet {
            let card = cards[index]
            try? await dataManager.deleteLoyaltyCard(with: card.id)
        }
        await loadCards()
    }
    
    func openNewCardDetails() {
        let maxOrder = cards.map(\.order).max() ?? 0
        let newCard = LoyaltyCard(id: UUID(), name: "", imageID: nil, order: maxOrder + 1)
        coordinator.openLoyaltyCardDetails(newCard, isNew: true, onDismiss: nil)
    }
    
    func openCardDetails(at index: Int) {
        guard index < cards.count else { return }
        coordinator.openLoyaltyCardDetails(cards[index], isNew: false, onDismiss: nil)
    }
    
    private func loadThumbnails() async {
        thumbnails = [:]
        for card in cards {
            guard let imageID = card.imageID else { continue }
            if let image = try? await dataManager.loadImage(baseFileName: imageID, type: .cardThumbnail) {
                thumbnails[card.id] = image
            }
        }
    }
}
