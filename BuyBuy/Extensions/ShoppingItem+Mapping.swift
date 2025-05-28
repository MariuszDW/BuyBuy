//
//  ShoppingItem+Mapping.swift
//  BuyBuy
//
//  Created by MDW on 20/05/2025.
//

import CoreData

extension ShoppingItem {
    init(entity: ShoppingItemEntity) {
        self.id = entity.id ?? UUID()
        self.listID = entity.list?.id ?? UUID()
        self.name = entity.name ?? ""
        self.note = entity.note ?? ""
        self.status = ShoppingItemStatus(rawValue: entity.status ?? "") ?? .pending
        self.order = Int(entity.order)
        self.price = entity.price?.doubleValue
        self.quantity = entity.quantity?.doubleValue
        self.unit = ShoppingItemUnit(string: entity.unit)
        
        if let imagesSet = entity.images as? Set<ShoppingItemImageEntity> {
            self.imageIDs = imagesSet.compactMap { $0.id }
        } else {
            self.imageIDs = []
        }
    }
}

extension ShoppingItemEntity {
    func update(from model: ShoppingItem, context: NSManagedObjectContext) {
        self.id = model.id
        self.name = model.name
        self.note = model.note
        self.status = model.status.rawValue
        self.order = Int64(model.order)
        self.price = model.price as NSNumber?
        self.quantity = model.quantity as NSNumber?
        self.unit = model.unit?.symbol

        if let oldImages = self.images as? Set<ShoppingItemImageEntity> {
            for imageEntity in oldImages {
                context.delete(imageEntity)
            }
            self.removeFromImages(oldImages as NSSet)
        }
        
        for imageID in model.imageIDs {
            let imageEntity = ShoppingItemImageEntity(context: context)
            imageEntity.id = imageID
            imageEntity.item = self
            self.addToImages(imageEntity)
        }
    }
}
