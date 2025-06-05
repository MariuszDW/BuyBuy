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
    private let coordinator: any AppCoordinatorProtocol

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

    func openCardPreview(_ card: LoyaltyCard) {
        coordinator.openLoyaltyCardPreview(with: card.imageID, onDismiss: nil)
    }
    
    func openCardPreview(at index: Int) {
        if index < cards.count {
            coordinator.openLoyaltyCardPreview(with: cards[index].imageID, onDismiss: nil)
        }
    }
    
    func deleteCard(at index: Int) async {
        if index < cards.count {
            try? await dataManager.deleteLoyaltyCard(with: cards[index].id)
            await loadCards()
        }
    }
    
    func openNewCardDetails() {
        let newCard = LoyaltyCard(id: UUID(), name: "", imageID: nil)
        coordinator.openLoyaltyCardDetails(newCard, isNew: true, onDismiss: { [weak self] in
            Task {
                await self?.loadCards()
            }
        })
    }
    
    func openCardDetails(at index: Int) {
        guard index < cards.count else { return }
        coordinator.openLoyaltyCardDetails(cards[index], isNew: false, onDismiss: { [weak self] in
            Task {
                await self?.loadCards()
            }
        })
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
