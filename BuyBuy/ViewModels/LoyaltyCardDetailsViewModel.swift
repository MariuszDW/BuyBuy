//
//  LoyaltyCardDetailsViewModel.swift
//  BuyBuy
//
//  Created by MDW on 04/06/2025.
//

import Foundation
import SwiftUI

@MainActor
final class LoyaltyCardDetailsViewModel: ObservableObject {
    @Published private var loyaltyCard: LoyaltyCard
    @Published private var thumbnail: UIImage? = nil
    
    private(set) var isNew: Bool
    
    let dataManager: DataManagerProtocol
    private var coordinator: any AppCoordinatorProtocol
    
    private var name: String {
        get { loyaltyCard.name }
        set { loyaltyCard.name = newValue }
    }
    
    // MARK: - Bindings
    
    var nameBinding: Binding<String> {
        Binding(get: { self.name }, set: { self.name = $0 })
    }
    
    init(card: LoyaltyCard, isNew: Bool = false, dataManager: DataManagerProtocol, coordinator: any AppCoordinatorProtocol) {
        self.loyaltyCard = card
        self.isNew = isNew
        self.coordinator = coordinator
        self.dataManager = dataManager
    }
    
    func applyChanges() async {
        loyaltyCard.prepareToSave()
        try? await dataManager.addOrUpdateLoyaltyCard(loyaltyCard)
    }
    
    func loadCardThumbnail() async {
        if let imageID = loyaltyCard.imageID {
            thumbnail = try? await dataManager.loadImage(baseFileName: imageID, type: .cardThumbnail)
        }
    }
}
