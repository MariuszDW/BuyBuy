//
//  LoyaltyCard+Mapping.swift
//  BuyBuy
//
//  Created by MDW on 02/06/2025.
//

import CoreData

extension LoyaltyCard {
    init(entity: LoyaltyCardEntity) {
        self.id = entity.id ?? UUID()
        self.name = entity.name ?? ""
        self.imageID = entity.imageID
    }
}

extension LoyaltyCardEntity {
    func update(from model: LoyaltyCard) {
        self.id = model.id
        self.name = model.name
        self.imageID = model.imageID
    }
}
