//
//  AppCoordinator.swift
//  BuyBuy
//
//  Created by MDW on 14/05/2025.
//

import Foundation
import SwiftUI
import Combine
import CloudKit
import StoreKit
import CoreData

@MainActor
final class AppCoordinator: ObservableObject, AppCoordinatorProtocol {
    static private(set) var currentInstance: AppCoordinator?
    static private(set) var pendingShares: [CKShare.Metadata] = []
    static var pendingShortcutItem: UIApplicationShortcutItem?
    @Published var navigationPath = NavigationPath()
    let sheetPresenter = SheetPresenter()
    private var preferences: AppPreferencesProtocol
    private var userActivityTracker: UserActivityTracker
    private let dataManager: DataManager
    private let hapticEngine: HapticEngine
    private var appInitialized = false
    
    private let eventSubject = PassthroughSubject<AppEvent, Never>()
    var eventPublisher: AnyPublisher<AppEvent, Never> {
        eventSubject.eraseToAnyPublisher()
    }
        
    init(preferences: AppPreferencesProtocol) {
        self.preferences = preferences
        self.dataManager = DataManager(useCloud: preferences.isCloudSyncEnabled)
        self.hapticEngine = HapticEngine(isEnabled: preferences.isHapticsEnabled)
        self.userActivityTracker = UserActivityTracker(preferences: preferences)
        Self.currentInstance = self
    }
    
    static func enqueuePendingShare(_ metadata: CKShare.Metadata) {
        if let coordinator = Self.currentInstance, coordinator.appInitialized {
            coordinator.acceptShare(metadata)
        } else {
            Self.pendingShares.append(metadata)
        }
    }
    
    func consumePendingShortcutIfAny() {
        guard let item = AppCoordinator.pendingShortcutItem else { return }
        AppCoordinator.pendingShortcutItem = nil

        guard let action = QuickActionType(rawValue: item.type) else {
            return
        }

        switch action {
        case .openLoyaltyCards:
            if !navigationPath.isLast(.loyaltyCards) {
                navigationPath.reset()
                openLoyaltyCardList()
            }
        }
    }
    
    func processPendingShares() {
        if dataManager.cloud {
            for share in Self.pendingShares {
                acceptShare(share)
            }
        }
        Self.pendingShares.removeAll()
    }
    
    func acceptShare(_ metadata: CKShare.Metadata) {
        guard dataManager.cloud else {
            return
        }
        
        guard metadata.participantRole != .owner else {
            AppLogger.general.notice("Invitation from owner – ignoring.")
            return
        }
        
        let container = dataManager.coreDataStack.container as! NSPersistentCloudKitContainer
        
        guard let sharedStore = dataManager.coreDataStack.sharedCloudPersistentStore else {
            AppLogger.general.info("No shared store.")
            return
        }

        container.acceptShareInvitations(from: [metadata], into: sharedStore) { acceptedMetadata, error in
            if let error {
                AppLogger.general.error("Error accepting share: \(error, privacy: .public)")
            } else {
                AppLogger.general.info("Share accepted: \(acceptedMetadata?.first?.share.recordID.recordName ?? "unknown", privacy: .public)")
            }
        }
    }
    
    func sendEvent(_ event: AppEvent) {
        eventSubject.send(event)
    }
    
    func setupDataManager(useCloud: Bool, completion: @escaping () -> Void = {}) async {
        dataManager.setup(useCloud: useCloud)
        
        if preferences.isCloudSyncEnabled != useCloud {
            preferences.isCloudSyncEnabled = useCloud
            sendEvent(.dataStorageChanged)
        }
        
        await MainActor.run {
            completion()
        }
        
#if BUYBUY_DEV
        // TODO: temporary, think about better place
//        await dataManager.printEnvironmentPaths()
#endif
    }
    
    // MARK: - Navigation and Sheet Management
    
    func openShoppingList(_ id: UUID) {
        navigationPath.append(AppRoute.shoppingList(id))
    }
    
    func openDeletedItems() {
        guard !navigationPath.isLast(.deletedItems) else { return }
        navigationPath.append(AppRoute.deletedItems)
    }
    
    func openAppSettings() {
        guard !navigationPath.isLast(.appSettings) else { return }
        navigationPath.append(AppRoute.appSettings)
    }
    
    func openLoyaltyCardList() {
        guard !navigationPath.isLast(.loyaltyCards) else { return }
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
        guard !navigationPath.isLast(.about) else { return }
        navigationPath.append(AppRoute.about)
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
        sheetPresenter.present(.shoppingListExport(list), displayStyle: .sheet, onDismiss: onDismiss)
    }
    
    func openDocumentExporter(with exportData: ExportedData, onDismiss: ((SheetRoute) -> Void)? = nil) {
        sheetPresenter.present(.documentExporter(exportData), displayStyle: .sheet, onDismiss: onDismiss)
    }
    
    func openTipJar(onDismiss: ((SheetRoute) -> Void)? = nil) {
        sheetPresenter.present(.tipJar, displayStyle: .sheet, onDismiss: onDismiss)
    }
    
    func openShoppingListShareManagement(with listID: UUID, title: String, onDismiss: ((SheetRoute) -> Void)? = nil) async {
        guard let share = try? await dataManager.fetchShoppingListCKShare(for: listID) else {
            AppLogger.general.error("Can not get CKShare for the list.")
            return
        }
        sheetPresenter.present(.sharingController(share: share, title: title), displayStyle: .sheet, onDismiss: onDismiss)
    }
    
    func showThankYou(for transaction: StoreKit.Transaction, onDismiss: ((SheetRoute) -> Void)? = nil) {
        sheetPresenter.present(.thankYou(transaction: transaction), displayStyle: .sheet, onDismiss: onDismiss)
    }
    
    func openInitAppSetup(onDismiss: ((SheetRoute) -> Void)? = nil) {
        sheetPresenter.present(.appInitialSetup, displayStyle: .fullScreen, onDismiss: onDismiss)
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
    
    // MARK: - View builders
    
    @ViewBuilder
    func view(for route: AppRoute) -> some View {
        switch route {
        case .shoppingLists:
            ShoppingListsView(
                viewModel: ShoppingListsViewModel(
                    dataManager: self.dataManager,
                    userActivityTracker: self.userActivityTracker,
                    coordinator: self,
                    preferences: self.preferences
                ),
                hapticEngine: self.hapticEngine
            )
            
        case .shoppingList(let id):
            ShoppingListView(
                viewModel: ShoppingListViewModel(
                    listID: id,
                    dataManager: self.dataManager,
                    coordinator: self
                ),
                hapticEngine: self.hapticEngine
            )
            
        case .deletedItems:
            DeletedItemsView(
                viewModel: DeletedItemsViewModel(
                    dataManager: self.dataManager,
                    coordinator: self
                ),
                hapticEngine: self.hapticEngine
            )
            
        case .appSettings:
            AppSettingsView(
                viewModel: AppSettingsViewModel(
                    dataManager: self.dataManager,
                    hapticEngine: self.hapticEngine,
                    preferences: self.preferences,
                    coordinator: self
                )
            )
            
        case .loyaltyCards:
            LoyaltyCardsView(
                viewModel: LoyaltyCardsViewModel(
                    dataManager: self.dataManager,
                    coordinator: self
                ),
                hapticEngine: self.hapticEngine
            )
            
        case .about:
            AboutView(
                viewModel: AboutViewModel(preferences: self.preferences,
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
                ),
                hapticEngine: self.hapticEngine
            )
            
        case let .shoppingListSelector(itemIDToRestore):
            ShoppingListSelectorView(
                viewModel: ShoppingListSelectorViewModel(
                    itemIDToRestore: itemIDToRestore,
                    dataManager: self.dataManager,
                    coordinator: self
                )
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
            
        case .tipJar:
            TipJarView(
                viewModel: TipJarViewModel(
                    userActivityTracker: self.userActivityTracker,
                    coordinator: self
                )
            )
            
        case .thankYou(let transaction):
            ThankYouView(
                viewModel: ThankYouViewModel(
                    transaction: transaction,
                    userActivityTracker: self.userActivityTracker,
                    coordinator: self
                )
            )
        
        case .sharingController(let share, let title):
            SharingControllerWrapper(share: share, shoppingListTitle: title)
            
        case .appInitialSetup:
            AppInitialSetupView(
                viewModel: AppInitialSetupViewModel(
                    preferences: self.preferences,
                    coordinator: self
                )
            )
        }
    }
    
    // MARK: - In-App Purchase
    
    func startTransactionListener() {
        Task.detached {
            for await result in Transaction.updates {
                switch result {
                case .verified(let transaction):
                    AppLogger.general.info("Verified transaction for: \(transaction.productID, privacy: .public)")
                    await self.showThankYou(for: transaction)
                case .unverified(let transaction, let error):
                    AppLogger.general.error("Unverified transaction for \(transaction.productID, privacy: .public): \(error, privacy: .public)")
                }
            }
        }
    }
    
    // MARK: - App scene phases
    
    func onAppStart() async {
        if preferences.installationDate == nil {
            openInitAppSetup()
        }
        startTransactionListener()
        appInitialized = true
        
        consumePendingShortcutIfAny()
        
        LegacyImageDataMigrator.runIfNeeded(dataManager: dataManager, preferences: preferences)
    }
    
    func onAppActive() {
        AppLogger.general.info("AppCoordinator.onAppActive()")
        Task { @MainActor in
            userActivityTracker.appDidActive()
            await performOnAppActiveTasks()
        }
    }

    func onAppInactive() {
        AppLogger.general.info("AppCoordinator.onAppInactive()")
        userActivityTracker.appDidInactive()
    }
    
    private func performOnAppActiveTasks() async {
        while !appInitialized {
            await Task.yield()
        }
        
        userActivityTracker.updateTipReminder()
        processPendingShares()

        let now = Date.now

        if let lastCleanupDate = preferences.lastCleanupDate {
            let secondsSince = now.timeIntervalSince(lastCleanupDate)
            let minutesSince = secondsSince / 60
            AppLogger.general.info("Last cleanup was: \(secondsSince.formattedDuration, privacy: .public) ago (\(lastCleanupDate, privacy: .public)).")
            if minutesSince > AppConstants.cleanupIntervalMinutes {
                Task(priority: .utility) {
                    await cleanupNotNeededData()
                }
                preferences.lastCleanupDate = now
            } else {
                AppLogger.general.info("Cleanup tasks not needed yet.")
            }
        } else {
            preferences.lastCleanupDate = now
        }
    }
    
    private func cleanupNotNeededData() async {
        AppLogger.general.info("Performing cleanup tasks.")

        try? await dataManager.cleanOrphanedShoppingItems()
        try? await dataManager.deleteOldTrashedShoppingItems(olderThan: AppConstants.autoDeleteAfterDays)

        if !preferences.legacyCloudImages && !preferences.legacyDeviceImages {
            await dataManager.cleanTemporaryImages()
        }
    }
    
    // MARK: - Handle memory warning
    
    func handleMemoryWarning() {
        AppLogger.general.info("Received memory warning")
        let dataManager = dataManager
        Task { @MainActor in
            await dataManager.cleanImageCache()
        }
    }
}
