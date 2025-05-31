//
//  ShoppingListRepository.swift
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

final actor ShoppingListsRepository: ShoppingListsRepositoryProtocol {
    private let coreDataStack: CoreDataStack
    private let saveQueue: SaveQueue
    
    init(coreDataStack: CoreDataStack) {
        self.coreDataStack = coreDataStack
        self.saveQueue = SaveQueue(newContext: { coreDataStack.newBackgroundContext() })
    }
    
    // MARK: - Lists
    
    func fetchAllLists() async throws -> [ShoppingList] {
        let context = coreDataStack.viewContext
        return try await context.perform {
            let request: NSFetchRequest<ShoppingListEntity> = ShoppingListEntity.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(keyPath: \ShoppingListEntity.order, ascending: true)]
            let entities = try context.fetch(request)
            return entities.map(ShoppingList.init)
        }
    }
    
    func fetchList(with id: UUID) async throws -> ShoppingList? {
        let context = coreDataStack.viewContext
        return try await context.perform {
            let request: NSFetchRequest<ShoppingListEntity> = ShoppingListEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id.uuidString)
            return try context.fetch(request).first.map(ShoppingList.init)
        }
    }
    
    func addOrUpdateList(_ list: ShoppingList) async throws {
        try await saveQueue.performSave { context in
            let request: NSFetchRequest<ShoppingListEntity> = ShoppingListEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", list.id.uuidString)
            
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
            request.predicate = NSPredicate(format: "id == %@", id.uuidString)
            
            if let entity = try context.fetch(request).first {
                context.delete(entity)
            }
        }
    }
    
    func deleteLists(with ids: [UUID]) async throws {
        try await saveQueue.performSave { context in
            let request: NSFetchRequest<ShoppingListEntity> = ShoppingListEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id IN %@", ids)
            
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
            request.sortDescriptors = [NSSortDescriptor(keyPath: \ShoppingItemEntity.order, ascending: true)]
            let entities = try context.fetch(request)
            return entities.map(ShoppingItem.init)
        }
    }
    
    func fetchItemsOfList(with listID: UUID) async throws -> [ShoppingItem] {
        let context = coreDataStack.viewContext
        return try await context.perform {
            let request: NSFetchRequest<ShoppingItemEntity> = ShoppingItemEntity.fetchRequest()
            request.predicate = NSPredicate(format: "list.id == %@", listID.uuidString)
            request.sortDescriptors = [NSSortDescriptor(keyPath: \ShoppingItemEntity.order, ascending: true)]
            let entities = try context.fetch(request)
            return entities.map(ShoppingItem.init)
        }
    }
    
    func fetchItem(with id: UUID) async throws -> ShoppingItem? {
        let context = coreDataStack.viewContext
        return try await context.perform {
            let request: NSFetchRequest<ShoppingItemEntity> = ShoppingItemEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id.uuidString)
            request.fetchLimit = 1
            let results = try context.fetch(request)
            return results.first.map(ShoppingItem.init)
        }
    }
    
    func fetchItems(with ids: [UUID]) async throws -> [ShoppingItem] {
        let context = coreDataStack.viewContext
        return try await context.perform {
            let request: NSFetchRequest<ShoppingItemEntity> = ShoppingItemEntity.fetchRequest()
            let uuidStrings = ids.map { $0.uuidString }
            request.predicate = NSPredicate(format: "id IN %@", uuidStrings)
            let results = try context.fetch(request)
            return results.map(ShoppingItem.init)
        }
    }
    
    func addOrUpdateItem(_ item: ShoppingItem) async throws {
        try await saveQueue.performSave { context in
            let request: NSFetchRequest<ShoppingItemEntity> = ShoppingItemEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", item.id.uuidString)
            
            if let entity = try context.fetch(request).first {
                if entity.list?.id != item.listID {
                    let listRequest: NSFetchRequest<ShoppingListEntity> = ShoppingListEntity.fetchRequest()
                    listRequest.predicate = NSPredicate(format: "id == %@", item.listID.uuidString)
                    guard let newList = try context.fetch(listRequest).first else {
                        throw NSError(domain: "ShoppingRepository", code: 4, userInfo: [NSLocalizedDescriptionKey: "New list not found"])
                    }
                    entity.list = newList
                }
                entity.update(from: item, context: context)
            } else {
                let listRequest: NSFetchRequest<ShoppingListEntity> = ShoppingListEntity.fetchRequest()
                listRequest.predicate = NSPredicate(format: "id == %@", item.listID.uuidString)
                guard let listEntity = try context.fetch(listRequest).first else {
                    throw NSError(domain: "ShoppingRepository", code: 2, userInfo: [NSLocalizedDescriptionKey: "List not found"])
                }
                
                let newEntity = ShoppingItemEntity(context: context)
                newEntity.update(from: item, context: context)
                newEntity.list = listEntity
            }
        }
    }
    
    func deleteItem(with id: UUID) async throws {
        try await saveQueue.performSave { context in
            let request: NSFetchRequest<ShoppingItemEntity> = ShoppingItemEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id.uuidString)
            if let entity = try context.fetch(request).first {
                context.delete(entity)
            }
        }
    }
    
    func deleteItems(with ids: [UUID]) async throws {
        try await saveQueue.performSave { context in
            let request: NSFetchRequest<ShoppingItemEntity> = ShoppingItemEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id IN %@", ids)
            let entities = try context.fetch(request)
            for entity in entities {
                context.delete(entity)
            }
        }
    }
    
    func cleanOrphanedItems() async throws {
        try await saveQueue.performSave { context in
            let request: NSFetchRequest<ShoppingItemEntity> = ShoppingItemEntity.fetchRequest()
            request.predicate = NSPredicate(format: "list == nil")
            
            let orphanedItems = try context.fetch(request)
            for item in orphanedItems {
                context.delete(item)
            }
        }
    }
}
