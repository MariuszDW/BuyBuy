//
//  MockDataRepository.swift
//  BuyBuy
//
//  Created by MDW on 20/05/2025.
//

import Foundation
import CloudKit

actor MockDataRepository: @preconcurrency DataRepositoryProtocol {
    var coreDataStack: CoreDataStackProtocol
    
    let shoppingLists: [ShoppingList]
    let loyaltyCards: [LoyaltyCard]
    let deletedItems: [ShoppingItem]

    init(lists: [ShoppingList] = MockDataRepository.allLists,
         cards: [LoyaltyCard] = MockDataRepository.allCards,
         deletedItems: [ShoppingItem] = MockDataRepository.deletedItems) {
        self.coreDataStack = MockCoreDataStack()
        self.shoppingLists = lists
        self.loyaltyCards = cards
        self.deletedItems = deletedItems
    }

    // MARK: - Shopping lists

    func fetchShoppingLists() async throws -> [ShoppingList] {
        return shoppingLists
    }

    func fetchShoppingList(with id: UUID) async throws -> ShoppingList? {
        return shoppingLists.first(where: { $0.id == id })
    }
    
    func addOrUpdateShoppingList(_ list: ShoppingList) async throws {}
    
    func deleteShoppingList(with id: UUID) async throws {}

    func deleteShoppingLists(with ids: [UUID]) async throws {}
    
    func deleteShoppingLists() async throws {}
    
    // MARK: - Sharing shopping list
    
    func fetchOrCreateShoppingListShare(for id: UUID) async throws -> CKShare? {
        return nil
    }
    
    func deleteShoppingListShare(for id: UUID) async throws {}
    
    func removeParticipantFromShoppingListShare(for id: UUID, participantRecordID: CKRecord.ID) async throws {}
    
    // MARK: - Shopping items

    func fetchShoppingItems() async throws -> [ShoppingItem] {
        return shoppingLists.flatMap { $0.items }
    }

    func fetchShoppingItemsOfList(with id: UUID) async throws -> [ShoppingItem] {
        return shoppingLists.first(where: { $0.id == id })?.items ?? []
    }

    func fetchShoppingItem(with id: UUID) async throws -> ShoppingItem? {
        for list in shoppingLists {
            if let item = list.items.first(where: { $0.id == id }) {
                return item
            }
        }
        return nil
    }

    func fetchShoppingItems(with ids: [UUID]) async throws -> [ShoppingItem] {
        return shoppingLists
            .flatMap { $0.items }
            .filter { ids.contains($0.id) }
    }
    
    func fetchDeletedShoppingItems() async throws -> [ShoppingItem] {
        return deletedItems
    }
    
    func fetchMaxOrderOfShoppingItems(ofList listID: UUID) async throws -> Int {
        guard let list = shoppingLists.first(where: { $0.id == listID }) else {
            return 0
        }
        let maxOrder = list.items.map { $0.order }.max() ?? 0
        return maxOrder
    }
    
    func fetchMaxOrderOfShoppingItems(ofList listID: UUID, status: ShoppingItemStatus) async throws -> Int {
        guard let list = shoppingLists.first(where: { $0.id == listID }) else {
            return 0
        }
        let maxOrder = list.items
            .filter { $0.status == status }
            .map { $0.order }
            .max() ?? 0
        return maxOrder
    }

    func addOrUpdateShoppingItem(_ item: ShoppingItem) async throws {}

    func deleteShoppingItem(with id: UUID) async throws {}

    func deleteShoppingItems(with ids: [UUID]) async throws {}
    
    func deleteShoppingItems() async throws {}
    
    func cleanOrphanedShoppingItems() async throws {}
    
    func fetchShoppingItemsWithMissingImages() async throws -> [ShoppingItem] {
        return []
    }

    // MARK: - Loyalty cards

    func fetchLoyaltyCards() async throws -> [LoyaltyCard] {
        return loyaltyCards
    }

    func fetchLoyaltyCard(with id: UUID) async throws -> LoyaltyCard? {
        return loyaltyCards.first(where: { $0.id == id })
    }

    func addOrUpdateLoyaltyCard(_ card: LoyaltyCard) async throws {}

    func deleteLoyaltyCard(with id: UUID) async throws {}
    
    func deleteLoyaltyCards() async throws {}
    
    func fetchLoyaltyCardsWithMissingImages() async throws -> [LoyaltyCard] {
        return []
    }
    
    // MARK: - Images
    
    func fetchImageData(id: String) async throws -> Data? {
        return nil
    }
        
    func fetchThumbnailData(id: String) async throws -> Data? {
        return nil
    }

    func fetchShoppingItemImageIDs() async throws -> Set<String> {
        return Set<String>()
    }

    func fetchLoyaltyCardImageIDs() async throws -> Set<String> {
        return Set<String>()
    }
    
    // MARK: - CloudKit
    
    nonisolated func fetchRemoteChangesFromCloudKit() {}
}

// MARK: Mock shopping lists

extension MockDataRepository {
    static let list1ID = UUID(uuidString: "00000000-0001-0000-0000-000000000000")!
    static let list2ID = UUID(uuidString: "00000000-0002-0000-0000-000000000000")!
    static let list3ID = UUID(uuidString: "00000000-0003-0000-0000-000000000000")!
    static let list4ID = UUID(uuidString: "00000000-0004-0000-0000-000000000000")!
    static let list5ID = UUID(uuidString: "00000000-0005-0000-0000-000000000000")!
    static let list6ID = UUID(uuidString: "00000000-0006-0000-0000-000000000000")!
    
    static let list1 = ShoppingList(id: list1ID, name: "Office", items: [
        ShoppingItem(
            id: UUID(uuidString: "00000000-0001-0001-0000-000000000000")!, order: 0, listID: list1ID,
            name: "A4 Printer Paper", note: "500 sheets, for montly reports.",
            status: .inactive, price: 5.99, quantity: 2, unit: ShoppingItemUnit(.piece)),
        ShoppingItem(
            id: UUID(uuidString: "00000000-0001-0002-0000-000000000000")!, order: 1, listID: list1ID,
            name: "Blue Ballpoint Pens", note: "Medium tip, blue ink.",
            status: .pending, price: 0.49, quantity: 10, unit: ShoppingItemUnit(.piece),
            imageIDs: ["00000000-0001-0002-0001-000000000000"]),
        ShoppingItem(
            id: UUID(uuidString: "00000000-0001-0003-0000-000000000000")!, order: 2, listID: list1ID,
            name: "Sticky Notes", note: "75x75 mm, yellow, repositionable.",
            status: .purchased, price: 1.20, quantity: 3, unit: ShoppingItemUnit(.piece)),
        ShoppingItem(
            id: UUID(uuidString: "00000000-0001-0004-0000-000000000000")!, order: 3, listID: list1ID,
            name: "Permanent Markers", note: "Black, waterproof ink.",
                status: .purchased, price: 0.89, quantity: 5, unit: ShoppingItemUnit(.piece)),
        ShoppingItem(
            id: UUID(uuidString: "00000000-0001-0005-0000-000000000000")!, order: 4, listID: list1ID,
            name: "Whiteboard Cleaner Spray", note: "In bottle 250 ml, for conference room use.",
            status: .purchased, price: 4.50, quantity: 1, unit: ShoppingItemUnit(.piece)),
        ShoppingItem(
            id: UUID(uuidString: "00000000-0001-0006-0000-000000000000")!, order: 5, listID: list1ID,
            name: "Highlighters (4 colors)", note: "Yellow, green, pink, orange.",
            status: .inactive, price: 3.50, quantity: 2, unit: ShoppingItemUnit(.piece)),
        ShoppingItem(
            id: UUID(uuidString: "00000000-0001-0007-0000-000000000000")!, order: 6, listID: list1ID,
            name: "Envelopes (C5, self-seal)", note: "For mailing invoices.",
            status: .purchased, price: 0.07, quantity: 100, unit: ShoppingItemUnit(.piece)),
        ShoppingItem(
            id: UUID(uuidString: "00000000-0001-0008-0000-000000000000")!, order: 7, listID: list1ID,
            name: "Correction Tape", note: "Better than fluid.",
            status: .pending, price: 2.30, quantity: 2, unit: ShoppingItemUnit(.piece)),
        ShoppingItem(
            id: UUID(uuidString: "00000000-0001-0009-0000-000000000000")!, order: 8, listID: list1ID,
            name: "Office Scissors (21cm)", note: "Stainless steel, right-handed.",
            status: .pending, price: 3.80, quantity: 1, unit: ShoppingItemUnit(.piece)),
        ShoppingItem(
            id: UUID(uuidString: "00000000-0001-0010-0000-000000000000")!, order: 9, listID: list1ID,
            name: "USB Flash Drive", note: "128 GB, USB-A type",
            status: .inactive, price: 6.99, quantity: 1, unit: ShoppingItemUnit(.piece),
            imageIDs: ["00000000-0001-0010-0001-000000000000"]),
        ShoppingItem(
            id: UUID(uuidString: "00000000-0001-0011-0000-000000000000")!, order: 10, listID: list1ID,
            name: "Binder Clips (25 mm)", note: "Black metal, medium size.",
            status: .pending, price: 0.15, quantity: 12, unit: ShoppingItemUnit(.piece),
            imageIDs: ["00000000-0001-0011-0001-000000000000"]),
        ShoppingItem(
            id: UUID(uuidString: "00000000-0001-0012-0000-000000000000")!, order: 11, listID: list1ID,
            name: "Desk Organizer", note: "Pen holder, tray, sticky note box.",
            status: .pending, price: 9.99, quantity: 1, unit: ShoppingItemUnit(.piece),
            imageIDs: ["00000000-0001-0012-0001-000000000000", "00000000-0001-0012-0002-000000000000"])
    ], icon: .paperclip, color: .indigo, isShared: false, isOwner: true, participants: [])
    
    static let list2 = ShoppingList(id: list2ID, name: "Fruits & Vegetables", items: [
        ShoppingItem(
            id: UUID(uuidString: "00000000-0002-0001-0000-000000000000")!, order: 0, listID: list2ID,
            name: "Bananas", note: "Ripe, medium size, for smoothies.",
            status: .pending, price: 0.35, quantity: 6, unit: ShoppingItemUnit(.piece)),
        ShoppingItem(
            id: UUID(uuidString: "00000000-0002-0002-0000-000000000000")!, order: 1, listID: list2ID,
            name: "Apples (Gala)", note: "Sweet and crisp, lunch snacks.",
            status: .pending, price: 0.45, quantity: 5, unit: ShoppingItemUnit(.piece)),
        ShoppingItem(
            id: UUID(uuidString: "00000000-0002-0003-0000-000000000000")!, order: 2, listID: list2ID,
            name: "Carrots", note: "Washed, medium size, for soup.",
            status: .purchased, price: 1.10, quantity: 1, unit: ShoppingItemUnit(.kilogram)),
        ShoppingItem(
            id: UUID(uuidString: "00000000-0002-0004-0000-000000000000")!, order: 3, listID: list2ID,
            name: "Tomatoes", note: "Ripe, vine, for sandwiches.",
            status: .purchased, price: 2.30, quantity: 1, unit: ShoppingItemUnit(.kilogram)),
        ShoppingItem(
            id: UUID(uuidString: "00000000-0002-0005-0000-000000000000")!, order: 4, listID: list2ID,
            name: "Spinach", note: "Fresh leaves, for salad.",
            status: .purchased, price: 1.75, quantity: 1, unit: ShoppingItemUnit(.piece)),
        ShoppingItem(
            id: UUID(uuidString: "00000000-0002-0006-0000-000000000000")!,
            order: 5, listID: list2ID, name: "Avocados", note: "Ripe, ready to eat.",
            status: .inactive, price: 1.20, quantity: 2, unit: ShoppingItemUnit(.piece)),
        ShoppingItem(
            id: UUID(uuidString: "00000000-0002-0007-0000-000000000000")!, order: 6, listID: list2ID,
            name: "Red Bell Peppers", note: "Crisp, for stir fry.",
            status: .purchased, price: 0.99, quantity: 3, unit: ShoppingItemUnit(.piece)),
        ShoppingItem(
            id: UUID(uuidString: "00000000-0002-0008-0000-000000000000")!, order: 7, listID: list2ID,
            name: "Lemons", note: "Juicy, for tea and dressing.",
            status: .pending, price: 0.55, quantity: 4, unit: ShoppingItemUnit(.piece)),
        ShoppingItem(
            id: UUID(uuidString: "00000000-0002-0009-0000-000000000000")!, order: 8, listID: list2ID,
            name: "Cucumbers", note: "Long, fresh, for sandwiches.",
            status: .pending, price: 0.85, quantity: 2, unit: ShoppingItemUnit(.piece)),
        ShoppingItem(
            id: UUID(uuidString: "00000000-0002-0010-0000-000000000000")!, order: 9, listID: list2ID,
            name: "Grapes (Green)", note: "Seedless, for snacking.",
            status: .inactive, price: 3.50, quantity: 1, unit: ShoppingItemUnit(.kilogram)),
        ShoppingItem(
            id: UUID(uuidString: "00000000-0002-0011-0000-000000000000")!,
            order: 10, listID: list2ID, name: "Onions (Yellow)", note: "For cooking, medium size.",
            status: .pending, price: 0.70, quantity: 1, unit: ShoppingItemUnit(.kilogram)),
        ShoppingItem(
            id: UUID(uuidString: "00000000-0002-0012-0000-000000000000")!, order: 11, listID: list2ID,
            name: "Parsley", note: "Fresh bunch, for garnish.",
            status: .inactive, price: 0.99, quantity: 1, unit: ShoppingItemUnit(.piece))
    ], icon: .flora, color: .green, isShared: false, isOwner: true, participants: [])
    
    static let list3 = ShoppingList(id: list3ID, name: "Groceries", items: [
        ShoppingItem(
            id: UUID(uuidString: "00000000-0003-0001-0000-000000000000")!, order: 0, listID: list3ID,
            name: "Whole Milk", note: "1 liter, full fat, for coffee and cereal.",
            status: .pending, price: 1.29, quantity: 2, unit: ShoppingItemUnit(.liter)),
        ShoppingItem(
            id: UUID(uuidString: "00000000-0003-0002-0000-000000000000")!, order: 1, listID: list3ID,
            name: "Eggs (Free-range)", note: "Medium size, pack of 10.",
            status: .pending, price: 2.49, quantity: 1, unit: ShoppingItemUnit(.piece)),
        ShoppingItem(
            id: UUID(uuidString: "00000000-0003-0003-0000-000000000000")!, order: 2, listID: list3ID,
            name: "Bread (Sourdough)", note: "Freshly baked, sliced.",
            status: .purchased, price: 3.10, quantity: 1, unit: ShoppingItemUnit(.piece)),
        ShoppingItem(
            id: UUID(uuidString: "00000000-0003-0004-0000-000000000000")!, order: 3, listID: list3ID,
            name: "Butter", note: "Unsalted, for baking.",
            status: .purchased, price: 2.20, quantity: 1, unit: ShoppingItemUnit(.piece)),
        ShoppingItem(
            id: UUID(uuidString: "00000000-0003-0005-0000-000000000000")!, order: 4, listID: list3ID,
            name: "Cheddar Cheese", note: "Mature, block, for sandwiches.",
            status: .purchased, price: 3.99, quantity: 1, unit: ShoppingItemUnit(.piece)),
        ShoppingItem(
            id: UUID(uuidString: "00000000-0003-0006-0000-000000000000")!, order: 5, listID: list3ID,
            name: "Rice (Basmati)", note: "1 kg bag, for curry.",
            status: .inactive, price: 2.75, quantity: 1, unit: ShoppingItemUnit(.kilogram)),
        ShoppingItem(
            id: UUID(uuidString: "00000000-0003-0007-0000-000000000000")!, order: 6, listID: list3ID,
            name: "Olive Oil", note: "Extra virgin, for salad dressing.",
            status: .purchased, price: 6.90, quantity: 1, unit: ShoppingItemUnit(.liter)),
        ShoppingItem(
            id: UUID(uuidString: "00000000-0003-0008-0000-000000000000")!, order: 7, listID: list3ID,
            name: "Tofu", note: "Firm, 300g, for stir fry.",
            status: .pending, price: 2.80, quantity: 1, unit: ShoppingItemUnit(.piece)),
        ShoppingItem(
            id: UUID(uuidString: "00000000-0003-0009-0000-000000000000")!, order: 8, listID: list3ID,
            name: "Yogurt (Natural)", note: "Plain, 400g cup.",
            status: .pending, price: 1.15, quantity: 2, unit: ShoppingItemUnit(.piece)),
        ShoppingItem(
            id: UUID(uuidString: "00000000-0003-0010-0000-000000000000")!, order: 9, listID: list3ID,
            name: "Pasta (Penne)", note: "500g bag, for dinner.",
            status: .inactive, price: 1.25, quantity: 1, unit: ShoppingItemUnit(.piece)),
        ShoppingItem(
            id: UUID(uuidString: "00000000-0003-0011-0000-000000000000")!, order: 10, listID: list3ID,
            name: "Tomato Sauce", note: "Glass jar, for pasta.",
            status: .pending, price: 1.99, quantity: 1, unit: ShoppingItemUnit(.piece)),
        ShoppingItem(
            id: UUID(uuidString: "00000000-0003-0012-0000-000000000000")!, order: 11, listID: list3ID,
            name: "Canned Chickpeas", note: "400g, for hummus and salads.",
            status: .inactive, price: 0.89, quantity: 2, unit: ShoppingItemUnit(.piece))
    ], icon: .cart, color: .red, isShared: true, isOwner: false, participants: [
        SharingParticipantInfo(displayName: "Igor", role: .publicUser, acceptanceStatus: .accepted, permission: .readWrite, userRecordID: CKRecord.ID(recordName: "rec1")),
        SharingParticipantInfo(displayName: "Irena", role: .publicUser, acceptanceStatus: .accepted, permission: .readOnly, userRecordID: CKRecord.ID(recordName: "rec1")),
        SharingParticipantInfo(displayName: "Natalia", role: .publicUser, acceptanceStatus: .pending, permission: .readWrite, userRecordID: CKRecord.ID(recordName: "rec1"))
    ])
    
    static let list4 = ShoppingList(id: list4ID, name: "Tools & Hardware", items: [
        ShoppingItem(
            id: UUID(uuidString: "00000000-0004-0001-0000-000000000000")!, order: 0, listID: list4ID,
            name: "Hammer", note: "500g, fiberglass handle.",
            status: .purchased, price: 14.99, quantity: 1, unit: ShoppingItemUnit(.piece)),
        ShoppingItem(
            id: UUID(uuidString: "00000000-0004-0002-0000-000000000000")!, order: 1, listID: list4ID,
            name: "Screwdriver Set", note: "Flat & Phillips, 6-piece set.",
            status: .pending, price: 19.99, quantity: 1, unit: ShoppingItemUnit(.piece)),
        ShoppingItem(
            id: UUID(uuidString: "00000000-0004-0003-0000-000000000000")!, order: 2, listID: list4ID,
            name: "Screws 4×40mm", note: "Zinc-coated wood screws, 100 pcs.",
            status: .pending, price: 4.99, quantity: 1, unit: ShoppingItemUnit(.piece)),
        ShoppingItem(
            id: UUID(uuidString: "00000000-0004-0004-0000-000000000000")!, order: 3, listID: list4ID,
            name: "Nails 2.5×60mm", note: "Steel, smooth shank, 200 pcs.",
            status: .purchased, price: 3.50, quantity: 1, unit: ShoppingItemUnit(.piece)),
        ShoppingItem(
            id: UUID(uuidString: "00000000-0004-0005-0000-000000000000")!, order: 4, listID: list4ID,
            name: "Washers M8", note: "Stainless steel, pack of 50.",
            status: .pending, price: 2.99, quantity: 1, unit: ShoppingItemUnit(.piece)),
        ShoppingItem(
            id: UUID(uuidString: "00000000-0004-0006-0000-000000000000")!, order: 5, listID: list4ID,
            name: "Hex Nuts M6", note: "Galvanized steel, DIN 934, 100 pcs.",
            status: .pending, price: 3.99, quantity: 1, unit: ShoppingItemUnit(.piece)),
        ShoppingItem(
            id: UUID(uuidString: "00000000-0004-0007-0000-000000000000")!, order: 6, listID: list4ID,
            name: "Drill Bit Set", note: "1–10mm, for metal and wood, 13 pcs.",
            status: .inactive, price: 24.99, quantity: 1, unit: ShoppingItemUnit(.piece)),
        ShoppingItem(
            id: UUID(uuidString: "00000000-0004-0008-0000-000000000000")!, order: 7, listID: list4ID,
            name: "Adjustable Wrench", note: "150mm, chrome finish.",
            status: .inactive, price: 9.99, quantity: 1, unit: ShoppingItemUnit(.piece)),
        ShoppingItem(
            id: UUID(uuidString: "00000000-0004-0009-0000-000000000000")!, order: 8, listID: list4ID,
            name: "Cable Ties 200mm", note: "Black nylon, 100 pcs.",
            status: .purchased, price: 5.49, quantity: 1, unit: ShoppingItemUnit(.piece)),
        ShoppingItem(
            id: UUID(uuidString: "00000000-0004-0010-0000-000000000000")!, order: 9, listID: list4ID,
            name: "Plastic Wall Plugs Ø8mm", note: "For concrete and brick, 50 pcs.",
            status: .pending, price: 3.99, quantity: 1, unit: ShoppingItemUnit(.piece)),
        ShoppingItem(
            id: UUID(uuidString: "00000000-0004-0011-0000-000000000000")!, order: 10, listID: list4ID,
            name: "Measuring Tape", note: "5 meters, retractable.",
            status: .purchased, price: 6.99, quantity: 1, unit: ShoppingItemUnit(.piece)),
        ShoppingItem(
            id: UUID(uuidString: "00000000-0004-0012-0000-000000000000")!, order: 11, listID: list4ID,
            name: "Sanding Paper P120", note: "230×280mm, medium grit, pack of 10.",
            status: .inactive, price: 3.49, quantity: 1, unit: ShoppingItemUnit(.piece))
    ], icon: .tool, color: .gray, isShared: true, isOwner: true, participants: [
        SharingParticipantInfo(displayName: "Igor", role: .owner, acceptanceStatus: .accepted, permission: .readWrite, userRecordID: CKRecord.ID(recordName: "rec1")),
        SharingParticipantInfo(displayName: "Irena", role: .publicUser, acceptanceStatus: .accepted, permission: .readOnly, userRecordID: CKRecord.ID(recordName: "rec2")),
        SharingParticipantInfo(displayName: "Natalia", role: .publicUser, acceptanceStatus: .pending, permission: .readWrite, userRecordID: CKRecord.ID(recordName: "rec3"))
    ])
    
    static let list5 = ShoppingList(id: list5ID, name: "Clothing Store", items: [
        ShoppingItem(
            id: UUID(uuidString: "00000000-0005-0001-0000-000000000000")!, order: 0, listID: list5ID,
            name: "Basic T-Shirt", note: "White, 100% cotton, size M.",
            status: .pending, price: 8.99, quantity: 2, unit: ShoppingItemUnit(.piece)),
        ShoppingItem(
            id: UUID(uuidString: "00000000-0005-0002-0000-000000000000")!, order: 1, listID: list5ID,
            name: "Denim Jacket", note: "Classic fit, blue, size L.",
            status: .purchased, price: 59.90, quantity: 1, unit: ShoppingItemUnit(.piece)),
        ShoppingItem(
            id: UUID(uuidString: "00000000-0005-0003-0000-000000000000")!, order: 2, listID: list5ID,
            name: "Chinos", note: "Beige, size 34.",
            status: .pending, price: 39.99, quantity: 1, unit: ShoppingItemUnit(.piece)),
        ShoppingItem(
            id: UUID(uuidString: "00000000-0005-0004-0000-000000000000")!, order: 3, listID: list5ID,
            name: "Casual Shoes", note: "Size 42, grey suede.",
            status: .inactive, price: 64.50, quantity: 1, unit: ShoppingItemUnit(string: "pair")),
        ShoppingItem(
            id: UUID(uuidString: "00000000-0005-0005-0000-000000000000")!, order: 4, listID: list5ID,
            name: "Sports Socks (3-pack)", note: "White cotton, breathable.",
            status: .purchased, price: 6.75, quantity: 1, unit: ShoppingItemUnit(string: "set")),
        ShoppingItem(
            id: UUID(uuidString: "00000000-0005-0006-0000-000000000000")!, order: 5, listID: list5ID,
            name: "Wool Scarf", note: "Dark green, 180 cm.",
            status: .pending, price: 17.00, quantity: 1, unit: ShoppingItemUnit(.piece)),
        ShoppingItem(
            id: UUID(uuidString: "00000000-0005-0007-0000-000000000000")!, order: 6, listID: list5ID,
            name: "Leather Gloves", note: "Black, size M.",
            status: .pending, price: 25.00, quantity: 1, unit: ShoppingItemUnit(string: "pair"))
    ], icon: .person, color: .magenta, isShared: false, isOwner: true, participants: [])
    
    static let list6 = ShoppingList(id: list6ID, name: "Empty", items: [
    ], icon: .questionmark, color: .yellow, isShared: false, isOwner: true, participants: [])
    
    static let deletedItems: [ShoppingItem] = [
        ShoppingItem(
            id: UUID(uuidString: "00000000-0000-0001-0000-000000000000")!, order: 0, listID: nil,
            name: "Notebook (A5)", note: "Lined, 100 pages, for meeting notes.",
            status: .purchased, price: 4.20, quantity: 2, unit: ShoppingItemUnit(.piece),
            deletedAt: Calendar.current.date(byAdding: .day, value: -1, to: Date())),
        ShoppingItem(
            id: UUID(uuidString: "00000000-0000-0002-0000-000000000000")!, order: 0, listID: nil,
            name: "Toothpaste", note: "Whitening, 75ml tube.",
            status: .pending, price: 2.99, quantity: 1, unit: ShoppingItemUnit(.piece),
            deletedAt: Calendar.current.date(byAdding: .day, value: -4, to: Date())),
        ShoppingItem(
            id: UUID(uuidString: "00000000-0000-0003-0000-000000000000")!, order: 0, listID: nil,
            name: "Laundry Detergent", note: "For color clothes, 2.1L.",
            status: .inactive, price: 12.49, quantity: 1, unit: ShoppingItemUnit(.liter),
            deletedAt: Calendar.current.date(byAdding: .day, value: -7, to: Date())),
        ShoppingItem(
            id: UUID(uuidString: "00000000-0000-0004-0000-000000000000")!, order: 0, listID: nil,
            name: "Olive Oil (Extra Virgin)", note: "Cold pressed, 500ml bottle.",
            status: .purchased, price: 7.95, quantity: 1, unit: ShoppingItemUnit(.liter),
            deletedAt: Calendar.current.date(byAdding: .day, value: -9, to: Date())),
        ShoppingItem(
            id: UUID(uuidString: "00000000-0000-0005-0000-000000000000")!, order: 0, listID: nil,
            name: "Paper Towels", note: "2 rolls, strong absorbency.",
            status: .purchased, price: 5.20, quantity: 2, unit: ShoppingItemUnit(.piece),
            deletedAt: Calendar.current.date(byAdding: .day, value: -11, to: Date())),
        ShoppingItem(
            id: UUID(uuidString: "00000000-0000-0006-0000-000000000000")!, order: 0, listID: nil,
            name: "Hand Soap", note: "Lavender scent, 300ml pump bottle.",
            status: .pending, price: 3.10, quantity: 1, unit: ShoppingItemUnit(.piece),
            deletedAt: Calendar.current.date(byAdding: .day, value: -13, to: Date())),
        ShoppingItem(
            id: UUID(uuidString: "00000000-0000-0007-0000-000000000000")!, order: 0, listID: nil,
            name: "LED Bulbs (E27)", note: "Warm white, 10W, energy saving.",
            status: .inactive, price: 8.99, quantity: 4, unit: ShoppingItemUnit(.piece),
            deletedAt: Calendar.current.date(byAdding: .day, value: -17, to: Date())),
        ShoppingItem(
            id: UUID(uuidString: "00000000-0000-0008-0000-000000000000")!, order: 0, listID: nil,
            name: "Garden Gloves", note: "Waterproof, size M.",
            status: .pending, price: 6.75, quantity: 1, unit: ShoppingItemUnit(.piece),
            deletedAt: Calendar.current.date(byAdding: .day, value: -21, to: Date())),
        ShoppingItem(
            id: UUID(uuidString: "00000000-0000-0009-0000-000000000000")!, order: 0, listID: nil,
            name: "Oat Milk", note: "Barista edition, 1L carton.",
            status: .purchased, price: 3.30, quantity: 2, unit: ShoppingItemUnit(.liter),
            deletedAt: Calendar.current.date(byAdding: .day, value: -26, to: Date())),
        ShoppingItem(
            id: UUID(uuidString: "00000000-0000-0010-0000-000000000000")!, order: 0, listID: nil,
            name: "Ziplock Bags", note: "Medium size, 30 pcs, freezer safe.",
            status: .inactive, price: 4.50, quantity: 1, unit: ShoppingItemUnit(.piece),
            deletedAt: Calendar.current.date(byAdding: .day, value: -29, to: Date()))
    ]
    
    static let allLists: [ShoppingList] = [list1, list2, list3, list4, list5, list6]
}

// MARK: Mock loyalty cards

extension MockDataRepository {
    static let card1 = LoyaltyCard(
        id: UUID(uuidString: "00000001-0000-0000-0000-000000000000")!,
        name: "MorphStore", imageID: "00000001-0000-0000-0001-000000000000", order: 0)
    
    static let card2 = LoyaltyCard(
        id: UUID(uuidString: "00000002-0000-0000-0000-000000000000")!,
        name: "EcoMart", imageID: "00000002-0000-0000-0001-000000000000", order: 1)
    
    static let card3 = LoyaltyCard(
        id: UUID(uuidString: "00000003-0000-0000-0000-000000000000")!,
        name: "AmiShop", imageID: "00000003-0000-0000-0001-000000000000", order: 2)
    
    static let card4 = LoyaltyCard(
        id: UUID(uuidString: "00000004-0000-0000-0000-000000000000")!,
        name: "Urban Wear", imageID: "00000004-0000-0000-0001-000000000000", order: 3)
    
    static let card5 = LoyaltyCard(
        id: UUID(uuidString: "00000005-0000-0000-0000-000000000000")!,
        name: "Fresh Basket", imageID: "00000005-0000-0000-0001-000000000000", order: 4)
    
    static let card6 = LoyaltyCard(
        id: UUID(uuidString: "00000006-0000-0000-0000-000000000000")!,
        name: "Casa Decor", imageID: "00000006-0000-0000-0001-000000000000", order: 5)
    
    static let card7 = LoyaltyCard(
        id: UUID(uuidString: "00000007-0000-0000-0000-000000000000")!,
        name: "TechNest", imageID: "00000007-0000-0000-0001-000000000000", order: 6)
    
    static let allCards: [LoyaltyCard] = [card1, card2, card3, card4, card5, card6, card7]
}
