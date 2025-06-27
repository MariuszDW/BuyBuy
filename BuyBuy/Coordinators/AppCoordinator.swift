//
//  AppCoordinator.swift
//  BuyBuy
//
//  Created by MDW on 14/05/2025.
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class AppCoordinator: ObservableObject, AppCoordinatorProtocol {
    @Published var navigationPath = NavigationPath()
    let sheetPresenter = SheetPresenter()
    private let dataManager: DataManager
    var preferences: AppPreferencesProtocol
    private(set) var appInitialized = false
    private var folderPresenters: [DirectoryFilePresenter] = []
    
    private let eventSubject = PassthroughSubject<AppEvent, Never>()
    var eventPublisher: AnyPublisher<AppEvent, Never> {
        eventSubject.eraseToAnyPublisher()
    }
        
    init(preferences: AppPreferencesProtocol) {
        self.preferences = preferences
        self.dataManager = DataManager(useCloud: preferences.isCloudSyncEnabled)
    }
    
    func sendEvent(_ event: AppEvent) {
        eventSubject.send(event)
    }
    
    func setupDataManager(useCloud: Bool) async {
        await dataManager.setup(useCloud: useCloud)
        
        for presenter in folderPresenters {
            NSFileCoordinator.removeFilePresenter(presenter)
        }
        folderPresenters.removeAll()
        
        if useCloud {
            if let itemImagesURL = await dataManager.imageStorage.directoryURL(for: .itemImage) {
                let presenter = DirectoryFilePresenter(directoryURL: itemImagesURL) {
                    Task { @MainActor in
                        self.sendEvent(.shoppingItemImageChanged)
                    }
                }
                folderPresenters.append(presenter)
                NSFileCoordinator.addFilePresenter(presenter)
            }
            
            if let itemImagesURL = await dataManager.imageStorage.directoryURL(for: .cardImage) {
                let presenter = DirectoryFilePresenter(directoryURL: itemImagesURL) {
                    Task { @MainActor in
                        self.sendEvent(.loyaltyCardImageChanged)
                    }
                }
                folderPresenters.append(presenter)
                NSFileCoordinator.addFilePresenter(presenter)
            }
        }
        
        if preferences.isCloudSyncEnabled != useCloud {
            preferences.isCloudSyncEnabled = useCloud
            sendEvent(.dataStorateChanged)
        }
        
#if DEBUG
        await printAppSandboxPaths() // TODO: temporary, think about better place
#endif
    }
    
    private func cleanupNotNeededData() async {
        if preferences.isCloudSyncEnabled {
            // TODO: implement...
        } else {
            try? await dataManager.cleanOrphanedItems()
            try? await dataManager.deleteOldTrashedItems(olderThan: AppConstants.autoDeleteAfterDays)
            try? await dataManager.cleanOrphanedItemImages()
            try? await dataManager.cleanOrphanedCardImages()
        }
    }
    
#if DEBUG
    private func printAppSandboxPaths() async {
        let fileManager = FileManager.default
        
        if let documents = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            print("Documents: \(documents.path)")
        }
        
        if let caches = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first {
            print("Caches: \(caches.path)")
        }
        
        if let preferences = fileManager
            .urls(for: .libraryDirectory, in: .userDomainMask)
            .first?
            .appendingPathComponent("Preferences")
        {
            print("Preferences: \(preferences.path)")
        }
        
        let tmp = NSTemporaryDirectory()
        print("tmp: \(tmp)")
        
        if let ubiquityURL = fileManager.url(forUbiquityContainerIdentifier: nil) {
            print("iCloud container: \(ubiquityURL.path)")
            print("iCloud Documents: \(ubiquityURL.appendingPathComponent("Documents").path)")
        } else {
            print("iCloud container is not available.")
        }
        
        let itemImagesFolder = await dataManager.imageStorage.directoryURL(for: .itemImage)
        let cardImagesFolder = await dataManager.imageStorage.directoryURL(for: .cardImage)
        print("Item images folder: \(itemImagesFolder?.absoluteString ?? "error")")
        print("Card images folder: \(cardImagesFolder?.absoluteString ?? "error")")
        
        let itemImages = try? await dataManager.imageStorage.listImageBaseNames(type: .itemImage)
        let cardImages = try? await dataManager.imageStorage.listImageBaseNames(type: .cardImage)
        print("List of item images:")
        itemImages?.forEach { print(" •", $0) }
        print("List of card images:")
        cardImages?.forEach { print(" •", $0) }
    }
#endif
    
    func performOnStartTasks() async {
        print("AppCoordinator.performOnStartTasks()")
        await setupDataManager(useCloud: preferences.isCloudSyncEnabled)
        appInitialized = true
    }
    
    func performOnForegroundTasks() async {
        while !appInitialized {
            await Task.yield()
        }
        print("AppCoordinator.performOnForegroundTasks()")
        let now = Date()
        
        if let lastCleanupDate = preferences.lastCleanupDate {
            let hoursSince = now.timeIntervalSince(lastCleanupDate) / 3600
            if hoursSince > AppConstants.cleanupIntervalHours {
                print("Performing cleanup tasks – last run was: \(lastCleanupDate)")
                Task(priority: .background) {
                    await cleanupNotNeededData()
                }
                preferences.lastCleanupDate = now
            }
        } else {
            preferences.lastCleanupDate = now
        }
    }
    
    func openShoppingList(_ id: UUID) {
        navigationPath.append(AppRoute.shoppingList(id))
    }
    
    func openDeletedItems() {
        navigationPath.append(AppRoute.deletedItems)
    }
    
    func openAppSettings() {
        navigationPath.append(AppRoute.appSettings)
    }
    
    func openLoyaltyCardList() {
        navigationPath.append(AppRoute.loyaltyCards)
    }
    
    func openShoppingListSettings(_ list: ShoppingList, isNew: Bool, onDismiss: ((SheetRoute) -> Void)? = nil) {
        sheetPresenter.present(.shoppingListSettings(list, isNew), onDismiss: onDismiss)
    }
    
    func openShoppingItemDetails(_ item: ShoppingItem, isNew: Bool, onDismiss: ((SheetRoute) -> Void)? = nil) {
        sheetPresenter.present(.shoppingItemDetails(item, isNew), onDismiss: onDismiss)
    }
    
    func openShoppingItemImage(with imageIDs: [String], index: Int, onDismiss: ((SheetRoute) -> Void)? = nil) {
        sheetPresenter.present(.shoppingItemImage(imageIDs, index), onDismiss: onDismiss)
    }
    
    func openLoyaltyCardPreview(with imageID: String?, onDismiss: ((SheetRoute) -> Void)? = nil) {
        sheetPresenter.present(.loyaltyCardPreview(imageID), onDismiss: onDismiss)
    }
    
    func openLoyaltyCardDetails(_ card: LoyaltyCard, isNew: Bool, onDismiss: ((SheetRoute) -> Void)? = nil) {
        sheetPresenter.present(.loyaltyCardDetails(card, isNew), onDismiss: onDismiss)
    }
    
    func openAbout() {
        sheetPresenter.present(.about)
    }
    
    func openShoppingListSelector(forDeletedItemID itemID: UUID, onDismiss: ((SheetRoute) -> Void)? = nil) {
        sheetPresenter.present(.shoppingListSelector(itemIDToRestore: itemID), displayStyle: .sheet, onDismiss: onDismiss)
    }
    
    func openEmail(to: String, subject: String, body: String) -> Bool {
        let subjectEncoded = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let bodyEncoded = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        guard let url = URL(string: "mailto:\(to)?subject=\(subjectEncoded)&body=\(bodyEncoded)"),
              UIApplication.shared.canOpenURL(url) else {
            return false
        }
        UIApplication.shared.open(url)
        return true
    }
    
    func openWebPage(address: String) -> Bool {
        guard let url = URL(string: address), UIApplication.shared.canOpenURL(url) else {
                return false
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
        return true
    }
    
    func openShoppingListExport(_ list: ShoppingList, onDismiss: ((SheetRoute) -> Void)? = nil) {
        sheetPresenter.present(.shoppingListExport(list), displayStyle: .fullScreen, onDismiss: onDismiss)
    }
    
    func openDocumentExporter(with exportData: ExportedData, onDismiss: ((SheetRoute) -> Void)? = nil) {
        sheetPresenter.present(.documentExporter(exportData), displayStyle: .sheet, onDismiss: onDismiss)
    }
    
    func closeTopSheet() {
        sheetPresenter.dismissTop()
    }
    
    func closeAllSheets() {
        sheetPresenter.dismissAll()
    }
    
    func back() {
        if !navigationPath.isEmpty {
            navigationPath.removeLast()
        }
    }
    
    func handleMemoryWarning() {
        print("Received memory warning")
        let dataManager = dataManager
        Task { @MainActor in
            await dataManager.cleanImageCache()
        }
    }

    @ViewBuilder
    func view(for route: AppRoute) -> some View {
        switch route {
        case .shoppingLists:
            ShoppingListsView(
                viewModel: ShoppingListsViewModel(
                    dataManager: self.dataManager,
                    coordinator: self
                )
            )
            
        case .shoppingList(let id):
            ShoppingListView(
                viewModel: ShoppingListViewModel(
                    listID: id,
                    dataManager: self.dataManager,
                    coordinator: self
                )
            )
            
        case .deletedItems:
            DeletedItemsView(
                viewModel: DeletedItemsViewModel(
                    dataManager: self.dataManager,
                    coordinator: self
                )
            )
            
        case .appSettings:
            AppSettingsView(
                viewModel: AppSettingsViewModel(dataManager: self.dataManager,
                                                preferences: self.preferences,
                                                coordinator: self)
            )
            
        case .loyaltyCards:
            LoyaltyCardsView(viewModel: LoyaltyCardsViewModel(dataManager: self.dataManager,
                                                              coordinator: self)
            )
        }
    }

    @ViewBuilder
    func sheetView(for sheet: SheetRoute) -> some View {
        switch sheet {
        case let .shoppingListSettings(list, isNew):
            ShoppingListSettingsView(
                viewModel: ShoppingListSettingsViewModel(
                    list: list,
                    isNew: isNew,
                    dataManager: self.dataManager,
                    coordinator: self
                )
            )
            
        case let .shoppingItemDetails(item, isNew):
            ShoppingItemDetailsView(
                viewModel: ShoppingItemDetailsViewModel(
                    item: item,
                    isNew: isNew,
                    dataManager: self.dataManager,
                    preferences: self.preferences,
                    coordinator: self
                )
            )
            
        case let .shoppingItemImage(imageIDs, index):
            FullScreenImageView(
                viewModel: FullScreenImageViewModel(
                    imageIDs: imageIDs,
                    startIndex: index,
                    imageType: .itemImage,
                    dataManager: self.dataManager,
                    coordinator: self
                )
            )
            
        case let .loyaltyCardPreview(imageID):
            let imageIDs: [String] = {
                guard let imageID = imageID else { return [] }
                return [imageID]
            }()
            FullScreenImageView(
                viewModel: FullScreenImageViewModel(
                    imageIDs: imageIDs,
                    startIndex: 0,
                    imageType: .cardImage,
                    dataManager: self.dataManager,
                    coordinator: self
                )
            )
            
        case let .loyaltyCardDetails(card, isNew):
            LoyaltyCardDetailsView(
                viewModel: LoyaltyCardDetailsViewModel(
                    card: card,
                    isNew: isNew,
                    dataManager: self.dataManager,
                    coordinator: self
                )
            )
            
        case let .shoppingListSelector(itemIDToRestore):
            ShoppingListSelectorView(
                viewModel: ShoppingListSelectorViewModel(
                    itemIDToRestore: itemIDToRestore,
                    dataManager: self.dataManager,
                    coordinator: self
                )
            )
            
        case .about:
            AboutView(
                viewModel: AboutViewModel(coordinator: self)
            )
            
        case let .shoppingListExport(list):
            ShoppingListExportView(
                viewModel: ShoppingListExportViewModel(
                    list: list,
                    coordinator: self
                )
            )
            
        case let .documentExporter(exportData):
            DocumentExporterView(
                data: exportData.data,
                fileName: exportData.fileName,
                fileExtension: exportData.fileExtension
            )
        }
    }
}
