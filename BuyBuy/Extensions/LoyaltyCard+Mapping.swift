//
//  LoyaltyCard+Mapping.swift
//  BuyBuy
//
//  Created by MDW on 02/06/2025.
//

import CoreData
import CloudKit

extension LoyaltyCard {
    init(entity: LoyaltyCardEntity) {
        self.id = entity.id ?? UUID()
        self.name = entity.name ?? ""
        self.imageID = entity.imageID
        self.order = Int(entity.order)
    }
}

extension LoyaltyCardEntity {
    func update(from model: LoyaltyCard, context: NSManagedObjectContext) {
        self.id = model.id
        self.name = model.name
        self.imageID = model.imageID
        self.order = Int64(model.order)
        
        guard let imageID = model.imageID else {
            self.image = nil
            self.thumbnail = nil
            return
        }
        
        lazy var storageManager = StorageManager()
        
        let imageEntity = self.image ?? BBImageEntity(context: context)
        if imageEntity.id == nil {
            imageEntity.id = UUID(uuidString: imageID)
        }
        if imageEntity.data == nil,
           let imageURL = storageManager.existingFileURL(for: .temporary, fileName: imageID + ".jpg"),
           let imageData = try? Data(contentsOf: imageURL) {
            imageEntity.data = imageData
        }
        self.image = imageEntity
        
        let thumbnailEntity = self.thumbnail ?? BBThumbnailEntity(context: context)
        if thumbnailEntity.id == nil {
            thumbnailEntity.id = UUID(uuidString: imageID)
        }
        if thumbnailEntity.data == nil,
           let thumbnailURL = storageManager.existingFileURL(for: .temporary, fileName: imageID + "_thumb.jpg"),
           let thumbnailData = try? Data(contentsOf: thumbnailURL) {
            thumbnailEntity.data = thumbnailData
        }
        self.thumbnail = thumbnailEntity
    }
}
