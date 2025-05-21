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
        
        self.items = nil
        for itemModel in model.items {
            let itemEntity = ShoppingItemEntity(context: context)
            itemEntity.update(from: itemModel, context: context)
            itemEntity.list = self
        }
    }
}
