//
//  ShoppingList+Mapping.swift
//  BuyBuy
//
//  Created by MDW on 20/05/2025.
//

import CoreData
import CloudKit

extension ShoppingList {
    init(entity: ShoppingListEntity, share: CKShare? = nil) {
        self.id = entity.id ?? UUID()
        self.name = entity.name ?? ""
        self.note = entity.note
        // self.order = Int(entity.order) // TODO: Order attribute is not necessary any more. Remove it in next CoreData model.
        self.icon = ListIcon(rawValue: entity.icon ?? "") ?? .default
        self.color = ListColor(rawValue: entity.color ?? "") ?? .default
        self.items = (entity.items as? Set<ShoppingItemEntity>)?.map(ShoppingItem.init) ?? []
        
        if let share = share {
            self.isShared = true
            self.isOwner = share.isOwnedByMe
            self.sharingParticipants = share.participantInfos
        } else {
            self.isShared = false
            self.isOwner = true
            self.sharingParticipants = []
        }
    }
}

extension ShoppingListEntity {
    func update(from model: ShoppingList, context: NSManagedObjectContext) {
        self.id = model.id
        self.name = model.name
        self.note = model.note
        // self.order = Int64(model.order) // TODO: Order attribute is not necessary any more. Remove it in next CoreData model.
        self.icon = model.icon.rawValue
        self.color = model.color.rawValue
        
        let existingItems = (self.items as? Set<ShoppingItemEntity>) ?? []
        let existingItemsMap = Dictionary(
            uniqueKeysWithValues:
                existingItems.compactMap { item in
                    item.id.map { ($0, item) }
                }
        )
        
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
