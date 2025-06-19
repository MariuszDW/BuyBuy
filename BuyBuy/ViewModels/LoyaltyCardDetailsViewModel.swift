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
    @Published var loyaltyCard: LoyaltyCard
    @Published var cardImage: UIImage? = nil
    @Published var loadingProgress: Bool = false
    
    private(set) var isNew: Bool
    var changesConfirmed: Bool = false
    
    private let dataManager: DataManagerProtocol
    var coordinator: any AppCoordinatorProtocol
    
    lazy var remoteChangeObserver: PersistentStoreChangeObserver = {
        PersistentStoreChangeObserver { [weak self] in
            guard let self = self else { return }
            await self.loadCard()
        }
    }()
    
    init(card: LoyaltyCard, isNew: Bool = false, dataManager: DataManagerProtocol, coordinator: any AppCoordinatorProtocol) {
        self.loyaltyCard = card
        self.isNew = isNew
        self.coordinator = coordinator
        self.dataManager = dataManager
    }
    
    func startObserving() {
        remoteChangeObserver.startObserving()
        print("LoyaltyCardDetailsViewModel - Started observing remote changes") // TODO: temp
    }
    
    func stopObserving() {
        remoteChangeObserver.stopObserving()
        print("LoyaltyCardDetailsViewModel - Stopped observing remote changes") // TODO: temp
    }
    
    func loadCard() async {
        print("LoyaltyCardDetailsViewModel.loadCard() called")
        guard let newLoyaltyCard = try? await dataManager.fetchLoyaltyCard(with: loyaltyCard.id) else { return }

        if newLoyaltyCard != loyaltyCard {
            let reloadImage = loyaltyCard.imageID != newLoyaltyCard.imageID
            loyaltyCard = newLoyaltyCard
            if reloadImage {
                await loadCardImage()
            }
        }
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
            try? await dataManager.deleteLoyaltyCard(with: loyaltyCard.id)
        }
        coordinator.sendEvent(.loyaltyCardEdited)
    }
    
    func openCardPreview() {
        guard let imageID = loyaltyCard.imageID else { return }
        coordinator.openLoyaltyCardPreview(with: imageID, onDismiss: nil)
    }
    
    func addCardImage(_ image: UIImage) async {
        let baseName = UUID().uuidString
        
        do {
            try await self.dataManager.saveImage(image, baseFileName: baseName, types: [.cardImage, .cardThumbnail])
            loyaltyCard.imageID = baseName
            await loadCardImage()
        } catch {
            print("Failed to save image: \(error)")
        }
    }
    
    func deleteCardImage() async {
        guard let imageID = loyaltyCard.imageID else { return }

        do {
            try await dataManager.deleteImage(baseFileName: imageID, types: [.cardImage, .cardThumbnail])
            loyaltyCard.imageID = nil
            await loadCardImage()
        } catch {
            print("Failed to delete image: \(error)")
        }
    }
    
    func loadCardImage() async {
        if let imageID = loyaltyCard.imageID {
            loadingProgress = true
            cardImage = try? await dataManager.loadImage(baseFileName: imageID, type: .cardImage)
        } else {
            cardImage = nil
        }
        loadingProgress = false
    }
}
