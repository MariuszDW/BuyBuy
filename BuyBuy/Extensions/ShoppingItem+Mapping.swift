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
        self.imageIDs = entity.imageIDs
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
    }
}
