//
//  DataRepository.swift
//  BuyBuy
//
//  Created by MDW on 20/05/2025.
//

import Foundation
import CoreData
import CloudKit

actor DataRepository: DataRepositoryProtocol {
    let coreDataStack: CoreDataStackProtocol
    private var saveQueue: SaveQueue {
        coreDataStack.saveQueue
    }
    
    init(useCloud: Bool) {
        self.coreDataStack = CoreDataStack(useCloudSync: useCloud)
    }
    
    // MARK: - Shopping lists
    
    func fetchShoppingLists() async throws -> [ShoppingList] {
        let context = coreDataStack.viewContext

        let request: NSFetchRequest<ShoppingListEntity> = ShoppingListEntity.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \ShoppingListEntity.id, ascending: true)
        ]

        let entities = try context.fetch(request)
        var shares: [NSManagedObjectID: CKShare] = [:]

        if coreDataStack.isCloud,
           let cloudContainer = coreDataStack.container as? NSPersistentCloudKitContainer {
            shares = (try? cloudContainer.fetchShares(matching: entities.map(\.objectID))) ?? [:]
        }

        let lists: [ShoppingList] = entities.map { entity in
            let share = shares[entity.objectID]
            return ShoppingList(entity: entity, share: share)
        }

        return lists
    }
    
    func fetchShoppingList(with id: UUID) async throws -> ShoppingList? {
        let context = coreDataStack.viewContext

        let request: NSFetchRequest<ShoppingListEntity> = ShoppingListEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        guard let entity = try context.fetch(request).first else { return nil }
        
        var share: CKShare? = nil
        if coreDataStack.isCloud, let cloudContainer = coreDataStack.container as? NSPersistentCloudKitContainer {
            share = try? cloudContainer.fetchShares(matching: [entity.objectID])[entity.objectID]
        }

        let list = ShoppingList(entity: entity, share: share)
        return list
    }
    
    func addOrUpdateShoppingList(_ list: ShoppingList) async throws {
        try await saveQueue.performSave { context in
            let request: NSFetchRequest<ShoppingListEntity> = ShoppingListEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", list.id as CVarArg)
            
            if let entity = try context.fetch(request).first {
                entity.update(from: list, context: context)
            } else {
                let newEntity = ShoppingListEntity(context: context)
                newEntity.update(from: list, context: context)
            }
        }
    }
    
    func deleteShoppingList(with id: UUID) async throws {
        try await saveQueue.performSave { context in
            let request: NSFetchRequest<ShoppingListEntity> = ShoppingListEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            
            if let entity = try context.fetch(request).first {
                context.delete(entity)
            }
        }
    }
    
    func deleteShoppingLists(with ids: [UUID]) async throws {
        guard !ids.isEmpty else { return }
        
        try await saveQueue.performSave { context in
            let request: NSFetchRequest<ShoppingListEntity> = ShoppingListEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id IN %@", ids as CVarArg)

            let entities = try context.fetch(request)
            for entity in entities {
                context.delete(entity)
            }
        }
    }
    
    func deleteShoppingLists() async throws {
        try await saveQueue.performSave { context in
            let request: NSFetchRequest<ShoppingListEntity> = ShoppingListEntity.fetchRequest()
            let entities = try context.fetch(request)
            for entity in entities {
                context.delete(entity)
            }
        }
    }
    
    // MARK: - Sharing shopping list
    
    func fetchShoppingListCKShare(for id: UUID) async throws -> CKShare? {
        guard let container = coreDataStack.container as? NSPersistentCloudKitContainer else {
            return nil
        }
        let context = coreDataStack.viewContext

        let request: NSFetchRequest<ShoppingListEntity> = ShoppingListEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)

        guard let entity = try context.fetch(request).first else { return nil }

        let shares = try container.fetchShares(matching: [entity.objectID])
        if let existingShare = shares[entity.objectID] {
            return existingShare
        }
        
        if context.hasChanges {
            try context.save()
        }

        // Create share only if I am the owner.
        do {
            let (_, share, _) = try await container.share([entity], to: nil)
            return share
        } catch let error as CKError where error.code == .permissionFailure {
            // A participant cannot create a share - return nil instead of throwing an error.
            return nil
        } catch {
            throw error
        }
    }
    
    // MARK: - Shopping items
    
    func fetchShoppingItems() async throws -> [ShoppingItem] {
        let context = coreDataStack.viewContext
        return try await context.perform {
            let request: NSFetchRequest<ShoppingItemEntity> = ShoppingItemEntity.fetchRequest()
            request.sortDescriptors = [
                NSSortDescriptor(keyPath: \ShoppingItemEntity.order, ascending: true),
                NSSortDescriptor(keyPath: \ShoppingItemEntity.id, ascending: true)
            ]
            let entities = try context.fetch(request)
            return entities.map(ShoppingItem.init)
        }
    }
    
    func fetchShoppingItemsOfList(with id: UUID) async throws -> [ShoppingItem] {
        let context = coreDataStack.viewContext
        return try await context.perform {
            let request: NSFetchRequest<ShoppingItemEntity> = ShoppingItemEntity.fetchRequest()
            request.predicate = NSPredicate(format: "list.id == %@", id as CVarArg)
            request.sortDescriptors = [
                NSSortDescriptor(keyPath: \ShoppingItemEntity.order, ascending: true),
                NSSortDescriptor(keyPath: \ShoppingItemEntity.id, ascending: true)
            ]
            let entities = try context.fetch(request)
            return entities.map(ShoppingItem.init)
        }
    }
    
    func fetchShoppingItem(with id: UUID) async throws -> ShoppingItem? {
        let context = coreDataStack.viewContext
        return try await context.perform {
            let request: NSFetchRequest<ShoppingItemEntity> = ShoppingItemEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            request.fetchLimit = 1
            let results = try context.fetch(request)
            return results.first.map(ShoppingItem.init)
        }
    }
    
    func fetchShoppingItems(with ids: [UUID]) async throws -> [ShoppingItem] {
        guard !ids.isEmpty else { return [] }
        
        let context = coreDataStack.viewContext
        return try await context.perform {
            let request: NSFetchRequest<ShoppingItemEntity> = ShoppingItemEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id IN %@", ids as CVarArg)
            let results = try context.fetch(request)
            return results.map(ShoppingItem.init)
        }
    }
    
    func fetchDeletedShoppingItems() async throws -> [ShoppingItem] {
        let context = coreDataStack.viewContext
        return try await context.perform {
            let request: NSFetchRequest<ShoppingItemEntity> = ShoppingItemEntity.fetchRequest()
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
                NSPredicate(format: "deletedAt != nil"),
                NSPredicate(format: "list == nil")
            ])
            request.sortDescriptors = [
                NSSortDescriptor(keyPath: \ShoppingItemEntity.deletedAt, ascending: false),
                NSSortDescriptor(keyPath: \ShoppingItemEntity.id, ascending: true)
            ]
            let entities = try context.fetch(request)
            return entities.map(ShoppingItem.init)
        }
    }
    
    func fetchMaxOrderOfShoppingItems(ofList listID: UUID) async throws -> Int {
        let context = coreDataStack.viewContext
        return try await context.perform {
            let request: NSFetchRequest<ShoppingItemEntity> = ShoppingItemEntity.fetchRequest()
            request.predicate = NSPredicate(format: "list.id == %@ AND deletedAt == nil", listID as CVarArg)
            request.sortDescriptors = [
                NSSortDescriptor(keyPath: \ShoppingItemEntity.order, ascending: false),
                NSSortDescriptor(keyPath: \ShoppingItemEntity.id, ascending: false)
            ]
            request.fetchLimit = 1

            let result = try context.fetch(request).first
            return Int(result?.order ?? 0)
        }
    }
    
    func fetchMaxOrderOfShoppingItems(ofList listID: UUID, status: ShoppingItemStatus) async throws -> Int {
        let context = coreDataStack.viewContext
        return try await context.perform {
            let request: NSFetchRequest<ShoppingItemEntity> = ShoppingItemEntity.fetchRequest()
            request.predicate = NSPredicate(
                format: "list.id == %@ AND deletedAt == nil AND status == %@",
                listID as CVarArg,
                status.rawValue
            )
            request.sortDescriptors = [
                NSSortDescriptor(keyPath: \ShoppingItemEntity.order, ascending: false),
                NSSortDescriptor(keyPath: \ShoppingItemEntity.id, ascending: false)
            ]
            request.fetchLimit = 1

            let result = try context.fetch(request).first
            return Int(result?.order ?? 0)
        }
    }
    
    func addOrUpdateShoppingItem(_ item: ShoppingItem) async throws {
        try await saveQueue.performSave { context in
            let request: NSFetchRequest<ShoppingItemEntity> = ShoppingItemEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", item.id as CVarArg)
            
            if let entity = try context.fetch(request).first {
                if entity.list?.id != item.listID {
                    if let listID = item.listID {
                        let listRequest: NSFetchRequest<ShoppingListEntity> = ShoppingListEntity.fetchRequest()
                        listRequest.predicate = NSPredicate(format: "id == %@", listID as CVarArg)
                        guard let newList = try context.fetch(listRequest).first else {
                            throw NSError(domain: "ShoppingRepository", code: 4, userInfo: [NSLocalizedDescriptionKey: "New list not found"])
                        }
                        entity.list = newList
                    } else {
                        entity.list = nil
                    }
                }
                entity.update(from: item, context: context)
            } else {
                let newEntity = ShoppingItemEntity(context: context)
                newEntity.update(from: item, context: context)
                
                if let listID = item.listID {
                    let listRequest: NSFetchRequest<ShoppingListEntity> = ShoppingListEntity.fetchRequest()
                    listRequest.predicate = NSPredicate(format: "id == %@", listID as CVarArg)
                    guard let listEntity = try context.fetch(listRequest).first else {
                        throw NSError(domain: "ShoppingRepository", code: 2, userInfo: [NSLocalizedDescriptionKey: "List not found"])
                    }
                    newEntity.list = listEntity
                } else {
                    newEntity.list = nil
                }
            }
        }
    }
    
    func deleteShoppingItem(with id: UUID) async throws {
        try await saveQueue.performSave { context in
            let request: NSFetchRequest<ShoppingItemEntity> = ShoppingItemEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            if let entity = try context.fetch(request).first {
                context.delete(entity)
            }
        }
    }
    
    func deleteShoppingItems(with ids: [UUID]) async throws {
        guard !ids.isEmpty else { return }
        
        try await saveQueue.performSave { context in
            let request: NSFetchRequest<ShoppingItemEntity> = ShoppingItemEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id IN %@", ids as CVarArg)
            let entities = try context.fetch(request)
            for entity in entities {
                context.delete(entity)
            }
        }
    }
    
    func deleteShoppingItems() async throws {
        try await saveQueue.performSave { context in
            let request: NSFetchRequest<ShoppingItemEntity> = ShoppingItemEntity.fetchRequest()
            let entities = try context.fetch(request)
            for entity in entities {
                context.delete(entity)
            }
        }
    }
    
    func cleanOrphanedShoppingItems() async throws {
        try await saveQueue.performSave { context in
            let request: NSFetchRequest<ShoppingItemEntity> = ShoppingItemEntity.fetchRequest()
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
                NSPredicate(format: "list == nil"),
                NSPredicate(format: "deletedAt == nil")
            ])
            let orphanedItems = try context.fetch(request)
            for item in orphanedItems {
                context.delete(item)
            }
        }
    }
    
    func fetchShoppingItemsWithMissingImages() async throws -> [ShoppingItem] {
        let context = coreDataStack.viewContext
        return try await context.perform {
            let request: NSFetchRequest<ShoppingItemEntity> = ShoppingItemEntity.fetchRequest()
            request.predicate = NSPredicate(format: "imageIDsData != nil") // tylko te z jakimiś imageIDs
            let entities = try context.fetch(request)

            var results: [ShoppingItem] = []

            for entity in entities {
                let uuids = entity.imageIDs.compactMap { UUID(uuidString: $0) }
                var missing = false
                
                for id in uuids {
                    let hasImage = (entity.images as? Set<BBImageEntity>)?.contains { image in
                        image.id == id
                    } ?? false

                    let hasThumbnail = (entity.thumbnails as? Set<BBThumbnailEntity>)?.contains { thumbnail in
                        thumbnail.id == id
                    } ?? false
                    
                    if !hasImage || !hasThumbnail {
                        missing = true
                        break
                    }
                }
                
                if missing {
                    results.append(ShoppingItem(entity: entity))
                }
            }

            return results
        }
    }
    
    // MARK: - Loyalty cards
    
    func fetchLoyaltyCards() async throws -> [LoyaltyCard] {
        let context = coreDataStack.viewContext
        return try await context.perform {
            let request: NSFetchRequest<LoyaltyCardEntity> = LoyaltyCardEntity.fetchRequest()
            request.sortDescriptors = [
                NSSortDescriptor(keyPath: \LoyaltyCardEntity.order, ascending: true),
                NSSortDescriptor(keyPath: \LoyaltyCardEntity.id, ascending: true)
            ]
            let entities = try context.fetch(request)
            return entities.map(LoyaltyCard.init)
        }
    }
    
    func fetchLoyaltyCard(with id: UUID) async throws -> LoyaltyCard? {
        let context = coreDataStack.viewContext
        return try await context.perform {
            let request: NSFetchRequest<LoyaltyCardEntity> = LoyaltyCardEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            return try context.fetch(request).first.map(LoyaltyCard.init)
        }
    }
    
    func addOrUpdateLoyaltyCard(_ card: LoyaltyCard) async throws {
        try await saveQueue.performSave { context in
            let request: NSFetchRequest<LoyaltyCardEntity> = LoyaltyCardEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", card.id as CVarArg)
            
            let entity = try context.fetch(request).first ?? LoyaltyCardEntity(context: context)
            entity.update(from: card, context: context)
        }
    }
    
    func deleteLoyaltyCard(with id: UUID) async throws {
        try await saveQueue.performSave { context in
            let request: NSFetchRequest<LoyaltyCardEntity> = LoyaltyCardEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            if let entity = try context.fetch(request).first {
                context.delete(entity)
            }
        }
    }
    
    func deleteLoyaltyCards() async throws {
        try await saveQueue.performSave { context in
            let request: NSFetchRequest<LoyaltyCardEntity> = LoyaltyCardEntity.fetchRequest()
            let entities = try context.fetch(request)
            for entity in entities {
                context.delete(entity)
            }
        }
    }
    
    func fetchLoyaltyCardsWithMissingImages() async throws -> [LoyaltyCard] {
        let context = coreDataStack.viewContext
        return try await context.perform {
            let request: NSFetchRequest<LoyaltyCardEntity> = LoyaltyCardEntity.fetchRequest()
            request.predicate = NSPredicate(format: "imageID != nil AND imageID != ''")
            let entities = try context.fetch(request)
            
            var results: [LoyaltyCard] = []

            for entity in entities {
                guard let idString = entity.imageID, let uuid = UUID(uuidString: idString) else {
                    results.append(LoyaltyCard(entity: entity))
                    continue
                }

                let hasImage = entity.image?.id == uuid
                let hasThumbnail = entity.thumbnail?.id == uuid

                if !hasImage || !hasThumbnail {
                    results.append(LoyaltyCard(entity: entity))
                }
            }

            return results
        }
    }
    
    // MARK: - Images
    
    func fetchImageData(id: String) async throws -> Data? {
        let context = coreDataStack.viewContext
        let request: NSFetchRequest<BBImageEntity> = BBImageEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        
        guard let entity = try? context.fetch(request).first else {
            return nil
        }
        
        return entity.data
    }
    
    func fetchThumbnailData(id: String) async throws -> Data? {
        let context = coreDataStack.viewContext
        let request: NSFetchRequest<BBThumbnailEntity> = BBThumbnailEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        
        guard let entity = try? context.fetch(request).first else {
            return nil
        }
        
        return entity.data
    }
    
    func fetchShoppingItemImageIDs() async throws -> Set<String> {
        let context = coreDataStack.viewContext
        return try await context.perform {
            let request: NSFetchRequest<ShoppingItemEntity> = ShoppingItemEntity.fetchRequest()
            let entities = try context.fetch(request)
            
            var allIDs = Set<String>()
            for entity in entities {
                let ids = entity.imageIDs
                allIDs.formUnion(ids)
            }
            return allIDs
        }
    }
    
    func fetchLoyaltyCardImageIDs() async throws -> Set<String> {
        let context = coreDataStack.viewContext
        return try await context.perform {
            let request: NSFetchRequest<LoyaltyCardEntity> = LoyaltyCardEntity.fetchRequest()
            let entities = try context.fetch(request)
            
            let allIDs = entities.compactMap { $0.imageID }
            return Set(allIDs)
        }
    }
    
    // MARK: - CloudKit
    
    nonisolated func fetchRemoteChangesFromCloudKit() {
        Task { @MainActor in
            await coreDataStack.fetchRemoteChanges()
        }
    }
}
