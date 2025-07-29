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
        
        let isCloud = context.isCloud
        
        guard isCloud == true else {
            self.sharedImage = nil
            return
        }

        if let imageID = model.imageID {
            let fetchRequest: NSFetchRequest<SharedImageEntity> = SharedImageEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", imageID)
            fetchRequest.fetchLimit = 1

            let entity = (try? context.fetch(fetchRequest).first) ?? SharedImageEntity(context: context)

            if entity.id == nil {
                entity.id = UUID(uuidString: imageID)
            }

            if entity.imageAsset == nil,
               let imageURL = ImageStorage.existingFileURL(for: imageID, type: .cardImage, cloud: isCloud),
               let imageData = try? Data(contentsOf: imageURL) {
                entity.imageAsset = imageData
            }

            if entity.thumbnailAsset == nil,
               let thumbnailURL = ImageStorage.existingFileURL(for: imageID, type: .cardThumbnail, cloud: isCloud),
               let thumbnailData = try? Data(contentsOf: thumbnailURL) {
                entity.thumbnailAsset = thumbnailData
            }

            entity.loyaltyCard = self
            self.sharedImage = entity
        } else {
            self.sharedImage = nil
        }
    }
}
