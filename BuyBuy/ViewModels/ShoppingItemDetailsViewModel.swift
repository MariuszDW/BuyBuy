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
    @Published var shoppingItem: ShoppingItem
    @Published var thumbnails: [UIImage] = []
    @Published var selectedImageID: String?
    @Published var shoppingLists: [ShoppingList] = []
    
    var changesConfirmed: Bool = false
    
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
    var coordinator: any AppCoordinatorProtocol
    
    var canConfirm: Bool {
        !shoppingItem.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var status: ShoppingItemStatus {
        get { shoppingItem.status }
        set { shoppingItem.status = newValue }
    }
    
    var listID: UUID {
        get { shoppingItem.listID }
        set { shoppingItem.listID = newValue }
    }
    
    var name: String {
        get { shoppingItem.name }
        set { shoppingItem.name = newValue }
    }
    
    var note: String {
        get { shoppingItem.note }
        set { shoppingItem.note = newValue }
    }
    
    var unit: String {
        get {
            shoppingItem.unit?.symbol ?? ""
        }
        set {
            shoppingItem.unit = ShoppingItemUnit(string: newValue)
        }
    }
    
    var quantityString: String {
        get { shoppingItem.quantity?.quantityFormat ?? "" }
        set { shoppingItem.quantity = newValue.quantityDouble }
    }
    
    var priceString: String {
        get { shoppingItem.price?.priceFormat ?? "" }
        set { shoppingItem.price = newValue.priceDouble }
    }
    
    var totalPriceString: String {
        shoppingItem.totalPrice?.priceFormat ?? String(localized: "none")
    }
    
    var quantityPlaceholder: String {
        let formatter = NumberFormatter.quantity()
        let valueString = formatter.string(from: 1.5) ?? "1.5"
        return String(localized: "for_example_short") + " \(valueString)"
    }
    
    var unitPlaceholder: String {
        let unitExampleString = Locale.current.measurementSystem == "Metric" ? MeasuredUnit.kilogram.symbol : MeasuredUnit.pound.symbol
        return String(localized: "for_example_short") + " \(unitExampleString)"
    }
    
    var pricePerUnitPlaceholder: String {
        let formatter = NumberFormatter.price()
        let valueString = formatter.string(from: 10.99) ?? "10.99"
        return String(localized: "for_example_short") + " \(valueString)"
    }
    
    init(item: ShoppingItem, isNew: Bool = false, dataManager: DataManagerProtocol, coordinator: any AppCoordinatorProtocol) {
        self.shoppingItem = item
        self.isNew = isNew
        self.coordinator = coordinator
        self.dataManager = dataManager
    }
    
    var itemList: ShoppingList? {
        return shoppingLists.first(where: { $0.id == shoppingItem.listID })
    }
    
    func openImagePreview(at index: Int) {
        guard index >= 0 && index < shoppingItem.imageIDs.count else { return }
        coordinator.openShoppingItemImage(with: shoppingItem.imageIDs, index: index, onDismiss: nil)
    }
    
    func addImage(_ image: UIImage) async {
        let baseName = UUID().uuidString
        
        do {
            try await self.dataManager.saveImage(image, baseFileName: baseName, types: [.itemImage, .itemThumbnail])
            
            shoppingItem.imageIDs.append(baseName)
            await loadThumbnails()
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
        } catch {
            print("Failed to delete image: \(error)")
        }
    }
    
    func loadThumbnails() async {
        self.thumbnails = []
        for id in shoppingItem.imageIDs {
            if let image = try? await dataManager.loadImage(baseFileName: id, type: .itemThumbnail) {
                self.thumbnails.append(image)
            }
        }
    }
    
    func loadShoppingLists() async {
        let fetchedLists = try? await dataManager.fetchAllLists()
        shoppingLists = fetchedLists ?? []
    }
    
    func finalizeInput() {
        shoppingItem.prepareToSave()
    }
    
    func didFinishEditing() async {
        if changesConfirmed {
            finalizeInput()
            try? await dataManager.addOrUpdateItem(shoppingItem)
        } else if isNew == true {
            try? await dataManager.deleteItem(shoppingItem)
        }
        coordinator.sendEvent(.shoppingItemEdited)
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
}
