//
//  DataRepository.swift
//  BuyBuy
//
//  Created by MDW on 20/05/2025.
//

import Foundation
import CoreData

/// A helper actor that serializes write operations to ensure they are executed one at a time.
actor SaveQueue {
    private let newContext: () -> NSManagedObjectContext
    
    init(newContext: @escaping () -> NSManagedObjectContext) {
        self.newContext = newContext
    }
    
    func performSave(_ block: @escaping (NSManagedObjectContext) throws -> Void) async throws {
        let context = newContext()
        return try await withCheckedThrowingContinuation { continuation in
            context.perform {
                do {
                    try block(context)
                    if context.hasChanges {
                        try context.save()
                    }
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

actor DataRepository: DataRepositoryProtocol {
    private let coreDataStack: CoreDataStackProtocol
    private let saveQueue: SaveQueue
    
    init(coreDataStack: CoreDataStackProtocol) {
        self.coreDataStack = coreDataStack
        self.saveQueue = SaveQueue(newContext: { coreDataStack.newBackgroundContext() })
    }
    
    // MARK: - Lists
    
    func fetchAllLists() async throws -> [ShoppingList] {
        let context = coreDataStack.viewContext
        return try await context.perform {
            let request: NSFetchRequest<ShoppingListEntity> = ShoppingListEntity.fetchRequest()
            request.sortDescriptors = [
                NSSortDescriptor(keyPath: \ShoppingListEntity.order, ascending: true),
                NSSortDescriptor(keyPath: \ShoppingListEntity.id, ascending: true)
            ]
            let entities = try context.fetch(request)
            return entities.map(ShoppingList.init)
        }
    }
    
    func fetchList(with id: UUID) async throws -> ShoppingList? {
        let context = coreDataStack.viewContext
        return try await context.perform {
            let request: NSFetchRequest<ShoppingListEntity> = ShoppingListEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            return try context.fetch(request).first.map(ShoppingList.init)
        }
    }
    
    func addOrUpdateList(_ list: ShoppingList) async throws {
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
    
    func deleteList(with id: UUID) async throws {
        try await saveQueue.performSave { context in
            let request: NSFetchRequest<ShoppingListEntity> = ShoppingListEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            
            if let entity = try context.fetch(request).first {
                context.delete(entity)
            }
        }
    }
    
    func deleteLists(with ids: [UUID]) async throws {
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
    
    func deleteAllLists() async throws {
        try await saveQueue.performSave { context in
            let request: NSFetchRequest<ShoppingListEntity> = ShoppingListEntity.fetchRequest()
            let entities = try context.fetch(request)
            for entity in entities {
                context.delete(entity)
            }
        }
    }
    
    // MARK: - Items
    
    func fetchAllItems() async throws -> [ShoppingItem] {
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
    
    func fetchItemsOfList(with listID: UUID) async throws -> [ShoppingItem] {
        let context = coreDataStack.viewContext
        return try await context.perform {
            let request: NSFetchRequest<ShoppingItemEntity> = ShoppingItemEntity.fetchRequest()
            request.predicate = NSPredicate(format: "list.id == %@", listID as CVarArg)
            request.sortDescriptors = [
                NSSortDescriptor(keyPath: \ShoppingItemEntity.order, ascending: true),
                NSSortDescriptor(keyPath: \ShoppingItemEntity.id, ascending: true)
            ]
            let entities = try context.fetch(request)
            return entities.map(ShoppingItem.init)
        }
    }
    
    func fetchItem(with id: UUID) async throws -> ShoppingItem? {
        let context = coreDataStack.viewContext
        return try await context.perform {
            let request: NSFetchRequest<ShoppingItemEntity> = ShoppingItemEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            request.fetchLimit = 1
            let results = try context.fetch(request)
            return results.first.map(ShoppingItem.init)
        }
    }
    
    func fetchItems(with ids: [UUID]) async throws -> [ShoppingItem] {
        guard !ids.isEmpty else { return [] }
        
        let context = coreDataStack.viewContext
        return try await context.perform {
            let request: NSFetchRequest<ShoppingItemEntity> = ShoppingItemEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id IN %@", ids as CVarArg)
            let results = try context.fetch(request)
            return results.map(ShoppingItem.init)
        }
    }
    
    func fetchDeletedItems() async throws -> [ShoppingItem] {
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
    
    func fetchMaxOrderOfItems(inList listID: UUID) async throws -> Int {
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
    
    func addOrUpdateItem(_ item: ShoppingItem) async throws {
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
    
    func deleteItem(with id: UUID) async throws {
        try await saveQueue.performSave { context in
            let request: NSFetchRequest<ShoppingItemEntity> = ShoppingItemEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            if let entity = try context.fetch(request).first {
                context.delete(entity)
            }
        }
    }
    
    func deleteItems(with ids: [UUID]) async throws {
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
    
    func deleteAllItems() async throws {
        try await saveQueue.performSave { context in
            let request: NSFetchRequest<ShoppingItemEntity> = ShoppingItemEntity.fetchRequest()
            let entities = try context.fetch(request)
            for entity in entities {
                context.delete(entity)
            }
        }
    }
    
    func cleanOrphanedItems() async throws {
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
    
    // MARK: - Item images
    
    func fetchAllItemImageIDs() async throws -> Set<String> {
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
    
    // MARK: - Loyalty Cards
    
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
            entity.update(from: card)
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
    
    func deleteAllLoyaltyCards() async throws {
        try await saveQueue.performSave { context in
            let request: NSFetchRequest<LoyaltyCardEntity> = LoyaltyCardEntity.fetchRequest()
            let entities = try context.fetch(request)
            for entity in entities {
                context.delete(entity)
            }
        }
    }
    
    // MARK: - Layalty Card images
    
    func fetchAllLoyaltyCardImageIDs() async throws -> Set<String> {
        let context = coreDataStack.viewContext
        return try await context.perform {
            let request: NSFetchRequest<LoyaltyCardEntity> = LoyaltyCardEntity.fetchRequest()
            let entities = try context.fetch(request)
            
            let allIDs = entities.compactMap { $0.imageID }
            return Set(allIDs)
        }
    }
}
