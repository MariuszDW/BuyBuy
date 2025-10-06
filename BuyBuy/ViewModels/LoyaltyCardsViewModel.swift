//
//  LoyaltyCardsViewModel.swift
//  BuyBuy
//
//  Created by MDW on 02/06/2025.
//

import Foundation
import SwiftUI
import Combine
import CoreData

@MainActor
final class LoyaltyCardsViewModel: ObservableObject {
    @Published var cards: [LoyaltyCard] = []
    @Published private(set) var thumbnails: [UUID: UIImage] = [:]
    
    private let dataManager: DataManagerProtocol
    private var coordinator: (any AppCoordinatorProtocol)?
    private var observerRegistered = false
    
    init(dataManager: DataManagerProtocol, coordinator: any AppCoordinatorProtocol) {
        self.dataManager = dataManager
        self.coordinator = coordinator
    }
    
    func startObserving() {
        guard !observerRegistered else { return }
        dataManager.persistentStoreChangeObserver.addObserver(self) { [weak self] in
            guard let self else { return }
            await self.loadCards()
        }
        observerRegistered = true
        AppLogger.general.debug("LoyaltyCardsViewModel - Started observing remote changes")
    }
    
    func stopObserving() {
        guard observerRegistered else { return }
        dataManager.persistentStoreChangeObserver.removeObserver(self)
        observerRegistered = false
        AppLogger.general.debug("LoyaltyCardsViewModel - Stopped observing remote changes")
    }
    
    var eventPublisher: AnyPublisher<AppEvent, Never> {
        coordinator?.eventPublisher ?? Empty().eraseToAnyPublisher()
    }
    
    func loadCards(fullRefresh: Bool = false) async {
        AppLogger.general.debug("LoyaltyCardsViewModel.loadCards(fullRefresh: \(fullRefresh, privacy: .public))")
        if fullRefresh {
            await dataManager.refreshAllCloudData()
        }
        guard let newCards = try? await dataManager.fetchLoyaltyCards() else { return }
        if newCards != cards {
            cards = newCards
            await loadThumbnails()
        }
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

    }

    func openCardPreview(_ card: LoyaltyCard) {
        coordinator?.openLoyaltyCardPreview(with: card.imageID, onDismiss: nil)
    }

    func openCardPreview(at index: Int) {
        if index < cards.count {
            coordinator?.openLoyaltyCardPreview(with: cards[index].imageID, onDismiss: nil)
        }
    }
    
    func deleteCard(with id: UUID) async {
        try? await dataManager.deleteLoyaltyCard(with: id)
    }
    
    func deleteCards(at indexSet: IndexSet) async {
        for index in indexSet {
            let card = cards[index]
            try? await dataManager.deleteLoyaltyCard(with: card.id)
        }
    }
    
    func openNewCardDetails() {
        let maxOrder = cards.map(\.order).max() ?? 0
        let newCard = LoyaltyCard(id: UUID(), name: "", imageID: nil, order: maxOrder + 1)
        coordinator?.openLoyaltyCardDetails(newCard, isNew: true, onDismiss: nil)
    }
    
    func openCardDetails(at index: Int) {
        guard index < cards.count else { return }
        coordinator?.openLoyaltyCardDetails(cards[index], isNew: false, onDismiss: nil)
    }
    
    func loadThumbnails() async {
        var newThumbnails: [UUID: UIImage] = [:]
        for card in cards {
            guard let imageID = card.imageID else { continue }
            if let image = try? await dataManager.loadThumbnail(with: imageID) {
                newThumbnails[card.id] = image
            }
        }
        thumbnails = newThumbnails
    }
}
