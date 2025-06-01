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
    @Published var imageThumbnails: [UIImage] = []
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
        shoppingItem.totalPriceString ?? "N/A"
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
    
    init(item: ShoppingItem, isNew: Bool = false, dataManager: DataManagerProtocol, coordinator: any AppCoordinatorProtocol) {
        self.shoppingItem = item
        self.isNew = isNew
        self.coordinator = coordinator
        self.dataManager = dataManager
        Task {
            await loadImageThumbnails()
        }
    }
    
    func openFullscreenImage(at index: Int) {
        guard index >= 0 && index < shoppingItem.imageIDs.count else { return }
        selectedImageID = shoppingItem.imageIDs[index]
    }
    
    func addImage(_ image: UIImage) async {
        let baseName = UUID().uuidString
        
        do {
            try await self.dataManager.saveImageAndThumbnail(image, baseFileName: baseName)
            
            shoppingItem.imageIDs.append(baseName)
            await loadImageThumbnails()
            await applyChanges()
            
        } catch {
            print("Failed to save image: \(error)")
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
    
    private func loadImageThumbnails() async {
        let dataManager = self.dataManager // TODO: sprawdzic czy teraz trzeba robic te kopie
        var images: [UIImage] = []
        for id in shoppingItem.imageIDs {
            if let image = try? await dataManager.loadThumbnail(baseFileName: id) {
                images.append(image)
            }
        }
        self.imageThumbnails = images
    }
}
