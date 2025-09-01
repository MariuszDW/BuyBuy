//
//  LegacyImageDataMigrator.swift
//  BuyBuy
//
//  Created by MDW on 27/08/2025.
//

import Foundation
import CoreData

@MainActor
final class LegacyImageDataMigrator {
    private let dataManager: DataManagerProtocol
    private var preferences: AppPreferencesProtocol
    private var storageManager: StorageManagerProtocol {
        dataManager.storageManager
    }
    
    private init(dataManager: DataManagerProtocol, preferences: AppPreferencesProtocol) {
        self.dataManager = dataManager
        self.preferences = preferences
    }
    
    static func runIfNeeded(dataManager: DataManagerProtocol,
                            preferences: AppPreferencesProtocol) {
        guard preferences.legacyCloudImages || preferences.legacyDeviceImages else {
            return
        }
            
        var candidates: [(DataManagerProtocol, Bool)] = []

        let currentFlag = dataManager.cloud ? preferences.legacyCloudImages : preferences.legacyDeviceImages
        if currentFlag {
            candidates.append((dataManager, true))
        }

        let secondFlag = !dataManager.cloud ? preferences.legacyCloudImages : preferences.legacyDeviceImages
        if secondFlag {
            let secondManager = DataManager(useCloud: !dataManager.cloud)
            candidates.append((secondManager, true))
        }

        let migrators = candidates.map { LegacyImageDataMigrator(dataManager: $0.0, preferences: preferences) }
        guard !migrators.isEmpty else { return }

        Task {
            for migrator in migrators {
                await migrator.performMigration()
            }
        }
    }
    
    func performMigration() async {
        if dataManager.cloud {
            await migrateCloud()
        } else {
            await migrateDevice()
        }
    }
    
    private func migrateCloud() async {
        let shoppingItems = try? await dataManager.fetchShoppingItemsWithMissingImages()
        let loyaltyCards = try? await dataManager.fetchLoyaltyCardsWithMissingImages()
        
        guard (shoppingItems?.count ?? 0) + (loyaltyCards?.count ?? 0) > 0 else {
            preferences.legacyCloudImages = false
            return
        }
        
        let totalCount = (shoppingItems?.count ?? 0) + (loyaltyCards?.count ?? 0)
        let timeout: TimeInterval = 3 * Double(totalCount)
        
        let cloudSubfolders = [["card_images"], ["item_images"]]
        await migrateFilesAndItems(from: .cloudDocuments, subfoldersList: cloudSubfolders, timeout: timeout, shoppingItems: shoppingItems, loyaltyCards: loyaltyCards)
        
        let newShoppingItemsCount = (try? await dataManager.fetchShoppingItemsWithMissingImages())?.count ?? 0
        let newLoyaltyCardsCount = (try? await dataManager.fetchLoyaltyCardsWithMissingImages())?.count ?? 0
        if newShoppingItemsCount + newLoyaltyCardsCount == 0 {
            preferences.legacyCloudImages = false
        }
    }
    
    private func migrateDevice() async {
        let shoppingItems = try? await dataManager.fetchShoppingItemsWithMissingImages()
        let loyaltyCards = try? await dataManager.fetchLoyaltyCardsWithMissingImages()
        
        guard (shoppingItems?.count ?? 0) + (loyaltyCards?.count ?? 0) > 0 else {
            preferences.legacyDeviceImages = false
            return
        }
        
        let localSubfolders = [["card_images"], ["item_images"]]
        await migrateFilesAndItems(from: .localDocuments, subfoldersList: localSubfolders, timeout: 0, shoppingItems: shoppingItems, loyaltyCards: loyaltyCards)
        
        preferences.legacyDeviceImages = false
    }
    
    private func migrateFilesAndItems(
        from storageType: StorageLocation,
        subfoldersList: [[String]],
        timeout: TimeInterval,
        shoppingItems: [ShoppingItem]? = nil,
        loyaltyCards: [LoyaltyCard]? = nil
    ) async {
        for subfolders in subfoldersList {
            let folderURL = storageManager.folderURL(for: storageType, subfolders: subfolders)
            if storageType == .cloudDocuments {
                await FileManager.default.downloadUbiquitousFiles(in: folderURL, timeout: timeout)
            }
            
            let files = storageManager.listFiles(in: storageType, subfolders: subfolders)
            for fileURL in files {
                storageManager.moveFile(
                    named: fileURL.lastPathComponent,
                    from: storageType, sourceSubfolders: subfolders,
                    to: .temporary, targetSubfolders: nil
                )
            }
            
            storageManager.deleteFolder(named: subfolders.last!, in: storageType, subfolders: subfolders.dropLast().map { $0 })
        }
        
        if let shoppingItems = shoppingItems {
            for item in shoppingItems {
                try? await dataManager.addOrUpdateShoppingItem(item)
            }
        }
        
        if let loyaltyCards = loyaltyCards {
            for card in loyaltyCards {
                try? await dataManager.addOrUpdateLoyaltyCard(card)
            }
        }
    }
}

extension FileManager {
    func downloadUbiquitousFiles(in folderURL: URL?, timeout: TimeInterval = 10) async {
        guard let folderURL = folderURL else { return }

        let urlsToDownload: [URL] = {
            guard let enumerator = self.enumerator(
                at: folderURL,
                includingPropertiesForKeys: [.isUbiquitousItemKey, .ubiquitousItemDownloadingStatusKey],
                options: [.skipsHiddenFiles]
            ) else { return [] }

            var urls: [URL] = []
            for case let fileURL as URL in enumerator {
                urls.append(fileURL)
            }
            return urls
        }()

        for fileURL in urlsToDownload {
            do {
                let resourceValues = try fileURL.resourceValues(forKeys: [.isUbiquitousItemKey, .ubiquitousItemDownloadingStatusKey])
                guard resourceValues.isUbiquitousItem == true else { continue }

                if let status = resourceValues.ubiquitousItemDownloadingStatus,
                   status != .current && status != .downloaded {

                    try self.startDownloadingUbiquitousItem(at: fileURL)

                    let startTime = Date()
                    while (try fileURL.resourceValues(forKeys: [.ubiquitousItemDownloadingStatusKey])
                                .ubiquitousItemDownloadingStatus ?? .current) != .current {
                        
                        if Date().timeIntervalSince(startTime) > timeout {
                            print("Timeout przy pobieraniu \(fileURL)")
                            break
                        }

                        try await Task.sleep(for: .milliseconds(200))
                    }
                }
            } catch {
                print("Błąd przy pobieraniu \(fileURL): \(error)")
            }
        }
    }
}
