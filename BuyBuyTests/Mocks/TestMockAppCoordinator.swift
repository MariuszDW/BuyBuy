//
//  MockAppCoordinator.swift
//  BuyBuyTests
//
//  Created by MDW on 14/05/2025.
//

import Foundation
import Combine
import StoreKit
@testable import BuyBuy

final class TestMockAppCoordinator: AppCoordinatorProtocol {
    func setupDataManager(useCloud: Bool, completion: @escaping () -> Void) async {
    }
    
    func openDeletedItems() {
    }
    
    func openTipJar(onDismiss: ((BuyBuy.SheetRoute) -> Void)?) {
    }
    
    func showThankYou(for transaction: Transaction, onDismiss: ((BuyBuy.SheetRoute) -> Void)?) {
    }
    
    var openShoppingListBlock: ((UUID) -> Void)?
    var backBlock: (() -> Void)?
    
    var eventPublisher = Empty<BuyBuy.AppEvent, Never>().eraseToAnyPublisher()
    
    func sendEvent(_ event: BuyBuy.AppEvent) {
    }
    
    func openShoppingList(_ id: UUID) {
        openShoppingListBlock?(id)
    }
    
    func openAppSettings() {
    }
    
    func openLoyaltyCardList() {
    }
    
    func openShoppingListSettings(_ list: BuyBuy.ShoppingList, isNew: Bool, onDismiss: ((BuyBuy.SheetRoute) -> Void)?) {
    }
    
    func openShoppingItemDetails(_ item: BuyBuy.ShoppingItem, isNew: Bool, onDismiss: ((BuyBuy.SheetRoute) -> Void)?) {
    }
    
    func openShoppingItemImage(with imageIDs: [String], index: Int, onDismiss: ((BuyBuy.SheetRoute) -> Void)?) {
    }
    
    func openLoyaltyCardPreview(with imageID: String?, onDismiss: ((BuyBuy.SheetRoute) -> Void)?) {
    }
    
    func openLoyaltyCardDetails(_ card: BuyBuy.LoyaltyCard, isNew: Bool, onDismiss: ((BuyBuy.SheetRoute) -> Void)?) {
    }
    
    func openAbout() {
    }
    
    func openShoppingListSelector(forDeletedItemID itemID: UUID, onDismiss: ((BuyBuy.SheetRoute) -> Void)?) {
    }
    
    func openEmail(to: String, subject: String, body: String) -> Bool {
        return false
    }
    
    func openWebPage(address: String) -> Bool {
        return false
    }
    
    func openShoppingListExport(_ list: BuyBuy.ShoppingList, onDismiss: ((BuyBuy.SheetRoute) -> Void)?) {
    }
    
    func openDocumentExporter(with exportData: BuyBuy.ExportedData, onDismiss: ((BuyBuy.SheetRoute) -> Void)?) {
    }
    
    func closeTopSheet() {
    }
    
    func closeAllSheets() {
    }
    
    func back() {
        backBlock?()
    }
}
