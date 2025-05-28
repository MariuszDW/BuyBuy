//
//  ShoppingItemDetailsViewModel.swift
//  BuyBuy
//
//  Created by MDW on 20/05/2025.
//

import Foundation
import SwiftUI

@MainActor
final class ShoppingItemDetailsViewModel: ObservableObject {
    /// The shopping item being edited.
    @Published private var shoppingItem: ShoppingItem
    
    /// Thumbnail of the shopping item images.
    @Published var imageThumbnails: [UIImage] = []
    
    /// Indicates whether the edited shopping list is a newly created one.
    private(set) var isNew: Bool
    
    /// Called when the user confirms changes to the edited ShoppingItem by tapping the OK button.
    private let onSave: () -> Void
    
    private let repository: ShoppingListsRepositoryProtocol
    private let imageStorage: ImageStorageServiceProtocol
    private var coordinator: any AppCoordinatorProtocol
    
    var status: ShoppingItemStatus {
        get { shoppingItem.status }
        set { shoppingItem.status = newValue }
    }
    
    private var name: String {
        get { shoppingItem.name }
        set { shoppingItem.name = newValue }
    }
    
    private var note: String {
        get { shoppingItem.note }
        set { shoppingItem.note = newValue }
    }
    
    private var quantity: Double? {
        get { shoppingItem.quantity }
        set { shoppingItem.quantity = newValue }
    }
    
    var unit: String {
        get {
            shoppingItem.unit?.symbol ?? ""
        }
        set {
            shoppingItem.unit = ShoppingItemUnit(string: newValue)
        }
    }
    
    private var price: Double? {
        get { shoppingItem.price }
        set { shoppingItem.price = newValue }
    }
    
    var totalPriceString: String {
        shoppingItem.totalPriceString ?? "N/A"
    }
    
    var isOkButtonDisabled: Bool {
        name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    // MARK: - Bindings
    
    var nameBinding: Binding<String> {
        Binding(get: { self.name }, set: { self.name = $0 })
    }
    
    var noteBinding: Binding<String> {
        Binding(get: { self.note }, set: { self.note = $0 })
    }
    
    var quantityBinding: Binding<Double?> {
        Binding(get: { self.quantity }, set: { self.quantity = $0 })
    }
    
    var unitBinding: Binding<String> {
        Binding(get: { self.unit }, set: { self.unit = $0 })
    }
    
    var priceBinding: Binding<Double?> {
        Binding(get: { self.price }, set: { self.price = $0 })
    }
    
    var quantityPlaceholder: String {
        let formatter = NumberFormatter.localizedDecimal(minFractionDigits: 1)
        let valueString = formatter.string(from: 1.5) ?? "1.5"
        return "e.g. \(valueString)"
    }
    
    var unitPlaceholder: String {
        let unitExampleString = Locale.current.measurementSystem == "Metric" ? MeasuredUnit.kilogram.symbol : MeasuredUnit.pound.symbol
        return "e.g. \(unitExampleString)"
    }
    
    var pricePerUnitPlaceholder: String {
        let formatter = NumberFormatter.localizedDecimal(minFractionDigits: 1)
        let valueString = formatter.string(from: 10.99) ?? "10.99"
        return "e.g. \(valueString)"
    }
    
    init(item: ShoppingItem, isNew: Bool = false, repository: ShoppingListsRepositoryProtocol, imageStorage: ImageStorageServiceProtocol, coordinator: any AppCoordinatorProtocol, onSave: @escaping () -> Void) {
        self.shoppingItem = item
        self.isNew = isNew
        self.coordinator = coordinator
        self.repository = repository
        self.imageStorage = imageStorage
        self.onSave = onSave
        loadImageThumbnails()
    }
    
    func handleThumbnailTap(at index: Int) {
        // TODO: Implement action on tap on a thumbnail at index.
        print("Tapped thumbnail at \(index).")
    }
    
    func addImage(_ image: UIImage) async {
        let baseName = UUID().uuidString
        
        do {
            try await Task.detached {
                try await self.imageStorage.saveImage(image, baseFileName: baseName)
                try await self.imageStorage.saveThumbnail(for: image, baseFileName: baseName)
            }.value
            
            await MainActor.run {
                shoppingItem.imageIDs.append(baseName)
                imageThumbnails.append(image)
            }
        } catch {
            print("Failed to save image: \(error)")
        }
    }
    
    func applyChanges() async {
        shoppingItem.prepareToSave()
        try? await repository.addOrUpdateItem(shoppingItem)
        onSave()
    }
    
    // MARK: - Private
    
    private func formatDouble(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }

    private func parseLocalizedDouble(_ string: String) -> Double? {
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        return formatter.number(from: string)?.doubleValue
    }
    
    private func loadImageThumbnails() {
        let imageStorage = self.imageStorage

        Task {
            var images: [UIImage] = []
            for id in shoppingItem.imageIDs {
                if let image = try? await imageStorage.loadThumbnail(baseFileName: id) {
                    images.append(image)
                }
            }

            await MainActor.run {
                self.imageThumbnails = images
            }
        }
    }
}
