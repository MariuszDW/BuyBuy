//
//  ShoppingItem+Mapping.swift
//  BuyBuy
//
//  Created by MDW on 20/05/2025.
//

import CoreData
import CloudKit

extension ShoppingItem {
    init(entity: ShoppingItemEntity) {
        self.id = entity.id ?? UUID()
        self.listID = entity.list?.id
        self.name = entity.name ?? ""
        self.note = entity.note ?? ""
        self.status = ShoppingItemStatus(rawValue: entity.status ?? "") ?? .pending
        self.order = Int(entity.order)
        self.price = entity.price?.doubleValue
        self.quantity = entity.quantity?.doubleValue
        self.unit = ShoppingItemUnit(string: entity.unit)
        self.imageIDs = entity.imageIDs
        self.deletedAt = entity.deletedAt
    }
}

extension ShoppingItemEntity {
    var imageIDs: [String] {
        get {
            guard let object = imageIDsData else { return [] }
            guard let data = object as? Data else {
                print("imageIDsData is not Data")
                return []
            }
            do {
                return try JSONDecoder().decode([String].self, from: data)
            } catch {
                print("Error decoding imageIDsData: \(error)")
                return []
            }
        }
        set {
            do {
                let data = try JSONEncoder().encode(newValue)
                imageIDsData = data as NSData
            } catch {
                print("Error encoding imageIDsData: \(error)")
                imageIDsData = nil
            }
        }
    }
    
    func update(from model: ShoppingItem, context: NSManagedObjectContext) {
        self.id = model.id
        self.name = model.name
        self.note = model.note
        self.status = model.status.rawValue
        self.order = Int64(model.order)
        self.price = model.price as NSNumber?
        self.quantity = model.quantity as NSNumber?
        self.unit = model.unit?.symbol
        self.imageIDs = model.imageIDs
        self.deletedAt = model.deletedAt
        
        let isCloud = context.isCloud
        
        guard isCloud == true else {
            self.sharedImages = nil
            return
        }
        
        var updatedSharedImages = Set<SharedImageEntity>()

        for imageID in model.imageIDs {
            let fetchRequest: NSFetchRequest<SharedImageEntity> = SharedImageEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", imageID)
            fetchRequest.fetchLimit = 1

            let entity = (try? context.fetch(fetchRequest).first) ?? SharedImageEntity(context: context)

            if entity.id == nil {
                entity.id = UUID(uuidString: imageID)
            }
            
            if entity.imageAsset == nil,
               let imageURL = ImageStorage.existingFileURL(for: imageID, type: .itemImage, cloud: isCloud),
               let imageData = try? Data(contentsOf: imageURL) {
                entity.imageAsset = imageData
            }

            if entity.thumbnailAsset == nil,
               let thumbnailURL = ImageStorage.existingFileURL(for: imageID, type: .itemThumbnail, cloud: isCloud),
               let thumbnailData = try? Data(contentsOf: thumbnailURL) {
                entity.thumbnailAsset = thumbnailData
            }

            entity.shoppingItem = self
            updatedSharedImages.insert(entity)
        }

        self.sharedImages = updatedSharedImages as NSSet
    }
}
