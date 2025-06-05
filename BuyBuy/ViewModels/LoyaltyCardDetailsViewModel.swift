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
    
    var changesConfirmed: Bool = false
    
    let dataManager: DataManagerProtocol
    var coordinator: any AppCoordinatorProtocol
    
    private var name: String {
        get { loyaltyCard.name }
        set { loyaltyCard.name = newValue }
    }
    
    var nameBinding: Binding<String> {
        Binding(get: { self.name }, set: { self.name = $0 })
    }
    
    init(card: LoyaltyCard, isNew: Bool = false, dataManager: DataManagerProtocol, coordinator: any AppCoordinatorProtocol) {
        self.loyaltyCard = card
        self.isNew = isNew
        self.coordinator = coordinator
        self.dataManager = dataManager
    }
    
    var canConfirm: Bool {
        !loyaltyCard.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    func finalizeInput() {
        loyaltyCard.prepareToSave()
    }
    
    func onFinishEditing() async {
        if changesConfirmed {
            finalizeInput()
            try? await dataManager.addOrUpdateLoyaltyCard(loyaltyCard)
        } else if isNew == true {
            try? await dataManager.deleteLoyaltyCard(loyaltyCard)
        }
        coordinator.sendEvent(.loyaltyCardEdited)
    }
    
    func loadCardThumbnail() async {
        if let imageID = loyaltyCard.imageID {
            thumbnail = try? await dataManager.loadImage(baseFileName: imageID, type: .cardThumbnail)
        }
    }
}
