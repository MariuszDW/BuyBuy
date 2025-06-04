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
    
    func openNewCardDetails(/*listID: UUID*/) {
        print("TODO: openNewCardDetails()")
        // TODO: implement...
//        let newItemStatus: ShoppingItemStatus = .pending
//        let uniqueUUID = UUID.unique(in: list?.items.map { $0.id })
//        let maxOrder = list?.items(for: newItemStatus).map(\.order).max() ?? 0
//        
//        let newItem = ShoppingItem(id: uniqueUUID, order: maxOrder + 1, listID: listID, name: "", status: newItemStatus)
//        
//        coordinator.openShoppingItemDetails(newItem, isNew: true, onDismiss: { [weak self] in
//            Task {
//                await self?.loadList()
//            }
//        })
    }
    
    func openCardDetails(_ card: LoyaltyCard) {
        print("TODO: openCardDetails()")
        // TODO: implement...
//        coordinator.openShoppingItemDetails(item, isNew: false, onDismiss: { [weak self] in
//            Task {
//                await self?.loadList()
//            }
//        })
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
