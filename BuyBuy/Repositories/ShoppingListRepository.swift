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
    
    func fetchList(id: UUID) async throws -> ShoppingList? {
        let context = coreDataStack.viewContext
        return try await context.perform {
            let request: NSFetchRequest<ShoppingListEntity> = ShoppingListEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            return try context.fetch(request).first.map(ShoppingList.init)
        }
    }

    func addList(_ list: ShoppingList) async throws {
        try await saveQueue.performSave { context in
            let entity = ShoppingListEntity(context: context)
            entity.update(from: list, context: context)
        }
    }

    func updateList(_ list: ShoppingList) async throws {
        try await saveQueue.performSave { context in
            let request: NSFetchRequest<ShoppingListEntity> = ShoppingListEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", list.id as CVarArg)
            guard let entity = try context.fetch(request).first else {
                throw NSError(domain: "ShoppingRepository", code: 1, userInfo: [NSLocalizedDescriptionKey: "List not found"])
            }
            entity.update(from: list, context: context)
        }
    }
    
    func deleteList(id: UUID) async throws {
        try await saveQueue.performSave { context in
            let request: NSFetchRequest<ShoppingListEntity> = ShoppingListEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id.uuidString)
            
            if let entity = try context.fetch(request).first {
                context.delete(entity)
            }
        }
    }
    
    func deleteLists(ids: [UUID]) async throws {
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

    func fetchItems(for listID: UUID) async throws -> [ShoppingItem] {
        let context = coreDataStack.viewContext
        return try await context.perform {
            let request: NSFetchRequest<ShoppingItemEntity> = ShoppingItemEntity.fetchRequest()
            request.predicate = NSPredicate(format: "list.id == %@", listID as CVarArg)
            request.sortDescriptors = [NSSortDescriptor(keyPath: \ShoppingItemEntity.order, ascending: true)]
            let entities = try context.fetch(request)
            return entities.map(ShoppingItem.init)
        }
    }

    func addItem(_ item: ShoppingItem) async throws {
        try await saveQueue.performSave { context in
            let listRequest: NSFetchRequest<ShoppingListEntity> = ShoppingListEntity.fetchRequest()
            listRequest.predicate = NSPredicate(format: "id == %@", item.listID as CVarArg)
            guard let listEntity = try context.fetch(listRequest).first else {
                throw NSError(domain: "ShoppingRepository", code: 2, userInfo: [NSLocalizedDescriptionKey: "List not found"])
            }

            let itemEntity = ShoppingItemEntity(context: context)
            itemEntity.update(from: item, context: context)
            itemEntity.list = listEntity
        }
    }

    func updateItem(_ item: ShoppingItem) async throws {
        try await saveQueue.performSave { context in
            let request: NSFetchRequest<ShoppingItemEntity> = ShoppingItemEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", item.id as CVarArg)
            guard let entity = try context.fetch(request).first else {
                throw NSError(domain: "ShoppingRepository", code: 3, userInfo: [NSLocalizedDescriptionKey: "Item not found"])
            }

            if entity.list?.id != item.listID {
                let listRequest: NSFetchRequest<ShoppingListEntity> = ShoppingListEntity.fetchRequest()
                listRequest.predicate = NSPredicate(format: "id == %@", item.listID as CVarArg)
                guard let newList = try context.fetch(listRequest).first else {
                    throw NSError(domain: "ShoppingRepository", code: 4, userInfo: [NSLocalizedDescriptionKey: "New list not found"])
                }
                entity.list = newList
            }

            entity.update(from: item, context: context)
        }
    }

    func deleteItem(_ item: ShoppingItem) async throws {
        try await saveQueue.performSave { context in
            let request: NSFetchRequest<ShoppingItemEntity> = ShoppingItemEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", item.id as CVarArg)
            if let entity = try context.fetch(request).first {
                context.delete(entity)
            }
        }
    }
}
