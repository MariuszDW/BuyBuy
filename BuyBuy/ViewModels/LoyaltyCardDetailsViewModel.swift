//
//  LoyaltyCardDetailsViewModel.swift
//  BuyBuy
//
//  Created by MDW on 04/06/2025.
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class LoyaltyCardDetailsViewModel: ObservableObject {
    @Published var loyaltyCard: LoyaltyCard
    @Published var cardImage: UIImage? = nil
    @Published var loadingProgress: Bool = false
    
    private(set) var isNew: Bool
    var changesConfirmed: Bool = false
    private let dataManager: DataManagerProtocol
    private var coordinator: (any AppCoordinatorProtocol)?
    private var observerRegistered = false
    
    init(card: LoyaltyCard, isNew: Bool = false, dataManager: DataManagerProtocol, coordinator: any AppCoordinatorProtocol) {
        self.loyaltyCard = card
        self.isNew = isNew
        self.coordinator = coordinator
        self.dataManager = dataManager
    }
    
    func startObserving() {
        guard !observerRegistered else { return }
        dataManager.persistentStoreChangeObserver.addObserver(self) { [weak self] in
            guard let self else { return }
            await self.loadCard()
        }
        observerRegistered = true
        print("LoyaltyCardDetailsViewModel - Started observing remote changes")
    }
    
    func stopObserving() {
        guard observerRegistered else { return }
        dataManager.persistentStoreChangeObserver.removeObserver(self)
        observerRegistered = false
        print("LoyaltyCardDetailsViewModel - Stopped observing remote changes")
    }
    
    var eventPublisher: AnyPublisher<AppEvent, Never> {
        coordinator?.eventPublisher ?? Empty().eraseToAnyPublisher()
    }
    
    func loadCard() async {
        print("LoyaltyCardDetailsViewModel.loadCard() called")
        guard let newLoyaltyCard = try? await dataManager.fetchLoyaltyCard(with: loyaltyCard.id) else { return }

        if newLoyaltyCard != loyaltyCard {
            let reloadImage = loyaltyCard.imageID != newLoyaltyCard.imageID
            loyaltyCard = newLoyaltyCard
            if reloadImage {
                try? await loadCardImage()
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
        coordinator?.sendEvent(.loyaltyCardEdited)
    }
    
    func openCardPreview() {
        guard let imageID = loyaltyCard.imageID else { return }
        coordinator?.openLoyaltyCardPreview(with: imageID, onDismiss: nil)
    }
    
    func addCardImage(_ image: UIImage) async {
        let baseName = UUID().uuidString
        
        do {
            try await self.dataManager.saveImageToTemporaryDir(image, baseFileName: baseName)
            loyaltyCard.imageID = baseName
            try await dataManager.addOrUpdateLoyaltyCard(loyaltyCard)
            try await loadCardImage()
        } catch {
            print("Failed to save image: \(error)")
        }
    }
    
    func deleteCardImage() async {
        if loyaltyCard.imageID != nil {
            loyaltyCard.imageID = nil
            try? await dataManager.addOrUpdateLoyaltyCard(loyaltyCard)
            try? await loadCardImage()
        }
    }
    
    func loadCardImage() async throws {
        if let imageID = loyaltyCard.imageID {
            loadingProgress = true
            do {
                cardImage = try await dataManager.loadImage(with: imageID)
            } catch {
                cardImage = nil
            }
        } else {
            cardImage = nil
        }
        loadingProgress = false
    }
}
