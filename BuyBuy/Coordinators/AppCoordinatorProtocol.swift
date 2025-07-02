//
//  AppCoordinatorProtocol.swift
//  BuyBuy
//
//  Created by MDW on 14/05/2025.
//

import Foundation
import Combine
import StoreKit

@MainActor
protocol AppCoordinatorProtocol: ObservableObject {
    var eventPublisher: AnyPublisher<AppEvent, Never> { get }
    func sendEvent(_ event: AppEvent)
    
    func setupDataManager(useCloud: Bool) async
    
    func openShoppingList(_ id: UUID)
    func openAppSettings()
    func openDeletedItems()
    func openLoyaltyCardList()
    func openShoppingListSettings(_ list: ShoppingList, isNew: Bool, onDismiss: ((SheetRoute) -> Void)?)
    func openShoppingItemDetails(_ item: ShoppingItem, isNew: Bool, onDismiss: ((SheetRoute) -> Void)?)
    func openShoppingItemImage(with imageIDs: [String], index: Int, onDismiss: ((SheetRoute) -> Void)?)
    func openLoyaltyCardPreview(with imageID: String?, onDismiss: ((SheetRoute) -> Void)?)
    func openLoyaltyCardDetails(_ card: LoyaltyCard, isNew: Bool, onDismiss: ((SheetRoute) -> Void)?)
    func openAbout()
    func openShoppingListSelector(forDeletedItemID itemID: UUID, onDismiss: ((SheetRoute) -> Void)?)
    func openEmail(to: String, subject: String, body: String) -> Bool
    func openWebPage(address: String) -> Bool
    func openShoppingListExport(_ list: ShoppingList, onDismiss: ((SheetRoute) -> Void)?)
    func openDocumentExporter(with exportData: ExportedData, onDismiss: ((SheetRoute) -> Void)?)
    func openTipJar(onDismiss: ((SheetRoute) -> Void)?)
    func showThankYou(for transaction: StoreKit.Transaction, onDismiss: ((SheetRoute) -> Void)?)
    func closeTopSheet()
    func closeAllSheets()
    func back()
}
