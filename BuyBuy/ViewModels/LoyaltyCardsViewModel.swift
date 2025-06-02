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

    func openCardCreation() {
        // TODO: implement...
        // coordinator.presentLoyaltyCardCreation()
    }
    
    private func loadThumbnails() async {
        thumbnails = [:]
        for card in cards {
            guard let imageID = card.imageID else { continue }
            if let image = try? await dataManager.loadCardThumbnail(baseFileName: imageID) {
                thumbnails[card.id] = image
            }
        }
    }
}
