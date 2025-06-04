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
    @Published var thumbnails: [UIImage] = []
    @Published var selectedImageID: String?
    
    var isFullscreenImagePresented: Binding<Bool> {
        Binding(
            get: { self.selectedImageID != nil },
            set: { newValue in
                if !newValue {
                    self.selectedImageID = nil
                }
            }
        )
    }
    
    /// Indicates whether the edited shopping list is a newly created one.
    private(set) var isNew: Bool
    
    let dataManager: DataManagerProtocol
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
        shoppingItem.totalPrice?.priceFormat ?? "N/A"
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
        let formatter = NumberFormatter.priceFormatter()
        let valueString = formatter.string(from: 10.99) ?? "10.99"
        return "e.g. \(valueString)"
    }
    
    init(item: ShoppingItem, isNew: Bool = false, dataManager: DataManagerProtocol, coordinator: any AppCoordinatorProtocol) {
        self.shoppingItem = item
        self.isNew = isNew
        self.coordinator = coordinator
        self.dataManager = dataManager
    }
    
    func openImagePreview(at index: Int) {
        guard index >= 0 && index < shoppingItem.imageIDs.count else { return }
        coordinator.openShoppingItemImage(with: shoppingItem.imageIDs[index], onDismiss: nil)
    }
    
    func addImage(_ image: UIImage) async {
        let baseName = UUID().uuidString
        
        do {
            try await self.dataManager.saveImage(image, baseFileName: baseName, types: [.itemImage, .itemThumbnail])
            
            shoppingItem.imageIDs.append(baseName)
            await loadThumbnails()
            await applyChanges()
            
        } catch {
            print("Failed to save image: \(error)")
        }
    }
    
    func deleteImage(at index: Int) async {
        guard index >= 0 && index < shoppingItem.imageIDs.count else { return }
        let id = shoppingItem.imageIDs.remove(at: index)

        do {
            try await dataManager.deleteImage(baseFileName: id, types: [.itemImage, .itemThumbnail])
            await loadThumbnails()
            await applyChanges()
        } catch {
            print("Failed to delete image: \(error)")
        }
    }
    
    func applyChanges() async {
        shoppingItem.prepareToSave()
        try? await dataManager.addOrUpdateItem(shoppingItem)
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
    
    func loadThumbnails() async {
        self.thumbnails = []
        for id in shoppingItem.imageIDs {
            if let image = try? await dataManager.loadImage(baseFileName: id, type: .itemThumbnail) {
                self.thumbnails.append(image)
            }
        }
    }
}
