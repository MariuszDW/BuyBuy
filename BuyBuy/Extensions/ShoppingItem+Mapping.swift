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
        
        lazy var storageManager = StorageManager()
        
        var updatedImages = Set<BBImageEntity>()
        var updatedThumbnails = Set<BBThumbnailEntity>()
        
        for imageID in model.imageIDs {
            guard let uuid = UUID(uuidString: imageID) else { continue }
            
            let imageEntity = imageEntity(for: uuid) ?? BBImageEntity(context: context)
            if imageEntity.id == nil {
                imageEntity.id = uuid
            }
            if imageEntity.data == nil,
               let imageURL = storageManager.existingFileURL(for: .temporary, fileName: imageID + ".jpg"),
               let imageData = try? Data(contentsOf: imageURL) {
                imageEntity.data = imageData
            }
            imageEntity.shoppingItem = self
            updatedImages.insert(imageEntity)
            
            let thumbnailEntity = thumbnailEntity(for: uuid) ?? BBThumbnailEntity(context: context)
            if thumbnailEntity.id == nil {
                thumbnailEntity.id = uuid
            }
            if thumbnailEntity.data == nil,
               let thumbURL = storageManager.existingFileURL(for: .temporary, fileName: imageID + "_thumb.jpg"),
               let thumbData = try? Data(contentsOf: thumbURL) {
                thumbnailEntity.data = thumbData
            }
            thumbnailEntity.shoppingItem = self
            updatedThumbnails.insert(thumbnailEntity)
        }
        
        self.images = updatedImages.isEmpty ? nil : updatedImages as NSSet
        self.thumbnails = updatedThumbnails.isEmpty ? nil : updatedThumbnails as NSSet
    }
    
    // MARK: - Helpers
    
    private func imageEntity(for id: UUID) -> BBImageEntity? {
        guard let images = images as? Set<BBImageEntity> else { return nil }
        return images.first { $0.id == id }
    }
    
    private func thumbnailEntity(for id: UUID) -> BBThumbnailEntity? {
        guard let thumbnails = thumbnails as? Set<BBThumbnailEntity> else { return nil }
        return thumbnails.first { $0.id == id }
    }
}
