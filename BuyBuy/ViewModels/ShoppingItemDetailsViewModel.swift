//
//  ShoppingItemDetailsViewModel.swift
//  BuyBuy
//
//  Created by MDW on 20/05/2025.
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class ShoppingItemDetailsViewModel: ObservableObject {
    @Published var shoppingItem: ShoppingItem
    @Published var thumbnails: [UIImage?] = []
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
    
    private let dataManager: DataManagerProtocol
    private var preferences: any AppPreferencesProtocol
    private var coordinator: (any AppCoordinatorProtocol)?
    private var observerRegistered = false
    
    var canConfirm: Bool {
        !shoppingItem.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var unit: String {
        get { shoppingItem.unit?.symbol ?? "" }
        set { shoppingItem.unit = ShoppingItemUnit(string: newValue) }
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
    
    init(item: ShoppingItem, isNew: Bool = false, dataManager: DataManagerProtocol, preferences: any AppPreferencesProtocol, coordinator: any AppCoordinatorProtocol) {
        self.shoppingItem = item
        self.isNew = isNew
        self.coordinator = coordinator
        self.dataManager = dataManager
        self.preferences = preferences
    }
    
    func startObserving() {
        guard !observerRegistered else { return }
        dataManager.persistentStoreChangeObserver.addObserver(self) { [weak self] in
            guard let self else { return }
            await self.loadShoppingItem()
            await self.loadShoppingLists()
        }
        observerRegistered = true
        print("ShoppingItemDetailsViewModel - Started observing remote changes")
    }
    
    func stopObserving() {
        guard observerRegistered else { return }
        dataManager.persistentStoreChangeObserver.removeObserver(self)
        observerRegistered = false
        print("ShoppingItemDetailsViewModel - Stopped observing remote changes")
    }
    
    var eventPublisher: AnyPublisher<AppEvent, Never> {
        coordinator?.eventPublisher ?? Empty().eraseToAnyPublisher()
    }
    
    lazy var unitList: [(name: String, units: [MeasuredUnit])] = {
        MeasuredUnit.buildUnitList(for: preferences.unitSystems)
    }()
    
    var itemList: ShoppingList? {
        return shoppingLists.first(where: { $0.id == shoppingItem.listID })
    }
    
    func openImagePreview(at index: Int) {
        guard index >= 0 && index < shoppingItem.imageIDs.count else { return }
        coordinator?.openShoppingItemImage(with: shoppingItem.imageIDs, index: index, onDismiss: nil)
    }
    
    func addImage(_ image: UIImage) async {
        let baseName = UUID().uuidString
        
        do {
            try await self.dataManager.saveImageToTemporaryDir(image, baseFileName: baseName)
            shoppingItem.imageIDs.append(baseName)
            try await dataManager.addOrUpdateShoppingItem(shoppingItem)
            await loadThumbnails()
        } catch {
            print("Failed to save image: \(error)")
        }
    }
    
    func moveToShoppingList(with listID: UUID) async {
        guard listID != shoppingItem.listID, let maxOrder = try? await dataManager.fetchMaxOrderOfShoppingItems(ofList: listID) else {
            return
        }
        try? await dataManager.deleteShoppingItem(with: shoppingItem.id)
        shoppingItem.moveToShoppingList(with: listID, order: maxOrder + 1)
        try? await dataManager.addOrUpdateShoppingItem(shoppingItem)
    }
    
    func deleteImage(at index: Int) async {
        guard index >= 0 && index < shoppingItem.imageIDs.count else { return }
        shoppingItem.imageIDs.remove(at: index)
        await loadThumbnails()
    }
    
    func loadShoppingItem() async {
        print("ShoppingItemDetailsViewModel.loadShoppingItem() called")
        guard let newShoppingItem = try? await dataManager.fetchShoppingItem(with: shoppingItem.id) else { return }
        if shoppingItem != newShoppingItem {
            let reloadImages = shoppingItem.imageIDs != newShoppingItem.imageIDs
            shoppingItem = newShoppingItem
            if reloadImages {
                await loadThumbnails()
            }
        }
    }
    
    func loadThumbnails() async {
        print("ShoppingItemDetailsViewModel.loadThumbnails() called")
        var newThumbnails: [UIImage?] = []
        for id in shoppingItem.imageIDs {
            if let image = try? await dataManager.loadThumbnail(with: id) {
                newThumbnails.append(image)
            } else {
                newThumbnails.append(nil)
            }
        }
        self.thumbnails = newThumbnails
    }
    
    func loadShoppingLists() async {
        print("ShoppingItemDetailsViewModel.loadShoppingLists() called")
        guard let newShoppingLists = try? await dataManager.fetchShoppingLists() else { return }
        if shoppingLists != newShoppingLists {
            shoppingLists = newShoppingLists
        }
    }
    
    func finalizeInput() {
        shoppingItem.prepareToSave()
    }
    
    func didFinishEditing() async {
        if changesConfirmed {
            finalizeInput()
            if isNew == true,
               let listID = shoppingItem.listID,
               let newOrder = try? await dataManager.fetchMaxOrderOfShoppingItems(ofList: listID, status: shoppingItem.status) {
                shoppingItem.order = newOrder + 1
            }
            try? await dataManager.addOrUpdateShoppingItem(shoppingItem)
        } else if isNew == true {
            try? await dataManager.deleteShoppingItem(with: shoppingItem.id)
        }
        coordinator?.sendEvent(.shoppingItemEdited)
    }
}
