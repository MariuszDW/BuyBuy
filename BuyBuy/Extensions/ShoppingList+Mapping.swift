//
//  ShoppingList+Mapping.swift
//  BuyBuy
//
//  Created by MDW on 20/05/2025.
//

import CoreData

extension ShoppingList {
    init(entity: ShoppingListEntity) {
        self.id = entity.id ?? UUID()
        self.name = entity.name ?? ""
        self.note = entity.note
        self.order = Int(entity.order)
        self.icon = ListIcon(rawValue: entity.icon ?? "") ?? .default
        self.color = ListColor(rawValue: entity.color ?? "") ?? .default
        self.items = (entity.items as? Set<ShoppingItemEntity>)?.map(ShoppingItem.init) ?? []
    }
}

extension ShoppingListEntity {
    func update(from model: ShoppingList, context: NSManagedObjectContext) {
        self.id = model.id
        self.name = model.name
        self.note = model.note
        self.order = Int64(model.order)
        self.icon = model.icon.rawValue
        self.color = model.color.rawValue
        
        let existingItems = (self.items as? Set<ShoppingItemEntity>) ?? []
        var existingItemsMap = [UUID: ShoppingItemEntity]()
        for item in existingItems {
            if let id = item.id {
                existingItemsMap[id] = item
            }
        }
        
        var updatedEntities = Set<ShoppingItemEntity>()
        let incomingIDs = Set(model.items.map(\.id))
        
        for itemModel in model.items {
            let entity = existingItemsMap[itemModel.id] ?? ShoppingItemEntity(context: context)
            entity.update(from: itemModel, context: context)
            entity.list = self
            updatedEntities.insert(entity)
        }
        
        let obsoleteItems = existingItems.filter { item in
            guard let id = item.id else { return false }
            return !incomingIDs.contains(id)
        }
        for item in obsoleteItems {
            context.delete(item)
        }
        
        self.items = updatedEntities as NSSet
    }
}
