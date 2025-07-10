//
//  MockDataRepository.swift
//  BuyBuy
//
//  Created by MDW on 20/05/2025.
//

import Foundation

actor MockDataRepository: DataRepositoryProtocol {
    nonisolated func fetchRemoteChangesFromCloudKit() {}
    
    let shoppingLists: [ShoppingList]
    let loyaltyCards: [LoyaltyCard]
    let deletedItems: [ShoppingItem]

    init(lists: [ShoppingList] = MockDataRepository.allLists,
         cards: [LoyaltyCard] = MockDataRepository.allCards,
         deletedItems: [ShoppingItem] = MockDataRepository.deletedItems) {
        self.shoppingLists = lists
        self.loyaltyCards = cards
        self.deletedItems = deletedItems
    }

    // MARK: - Lists

    func fetchAllLists() async throws -> [ShoppingList] {
        return shoppingLists
    }

    func fetchList(with id: UUID) async throws -> ShoppingList? {
        return shoppingLists.first(where: { $0.id == id })
    }
    
    func fetchMaxOrderOfItems(inList listID: UUID) async throws -> Int {
        guard let list = shoppingLists.first(where: { $0.id == listID }) else {
            return 0
        }
        let maxOrder = list.items.map { $0.order }.max() ?? 0
        return maxOrder
    }

    func addOrUpdateList(_ list: ShoppingList) async throws {}

    func deleteList(with id: UUID) async throws {}

    func deleteLists(with ids: [UUID]) async throws {}
    
    func deleteAllLists() async throws {}

    // MARK: - Items

    func fetchAllItems() async throws -> [ShoppingItem] {
        return shoppingLists.flatMap { $0.items }
    }

    func fetchItemsOfList(with listID: UUID) async throws -> [ShoppingItem] {
        return shoppingLists.first(where: { $0.id == listID })?.items ?? []
    }

    func fetchItem(with id: UUID) async throws -> ShoppingItem? {
        for list in shoppingLists {
            if let item = list.items.first(where: { $0.id == id }) {
                return item
            }
        }
        return nil
    }

    func fetchItems(with ids: [UUID]) async throws -> [ShoppingItem] {
        return shoppingLists
            .flatMap { $0.items }
            .filter { ids.contains($0.id) }
    }
    
    func fetchDeletedItems() async throws -> [ShoppingItem] {
        return deletedItems
    }

    func addOrUpdateItem(_ item: ShoppingItem) async throws {}

    func deleteItem(with id: UUID) async throws {}

    func deleteItems(with ids: [UUID]) async throws {}
    
    func deleteAllItems() async throws {}
    
    func cleanOrphanedItems() async throws {}

    // MARK: - Item images

    func fetchAllItemImageIDs() async throws -> Set<String> {
        return Set<String>()
    }

    // MARK: - Loyalty Cards

    func fetchLoyaltyCards() async throws -> [LoyaltyCard] {
        return loyaltyCards
    }

    func fetchLoyaltyCard(with id: UUID) async throws -> LoyaltyCard? {
        return loyaltyCards.first(where: { $0.id == id })
    }

    func addOrUpdateLoyaltyCard(_ card: LoyaltyCard) async throws {}

    func deleteLoyaltyCard(with id: UUID) async throws {}
    
    func deleteAllLoyaltyCards() async throws {}

    // MARK: - Loyalty card images

    func fetchAllLoyaltyCardImageIDs() async throws -> Set<String> {
        return Set<String>()
    }
}

// MARK: Mock shopping lists

extension MockDataRepository {
    static let listUUID1 = UUID(uuidString: "11111111-1111-1111-1111-111111111111")!
    static let listUUID2 = UUID(uuidString: "11111111-1111-1111-1112-111111111111")!
    static let listUUID3 = UUID(uuidString: "11111111-1111-1111-1113-111111111111")!
    static let listUUID4 = UUID(uuidString: "11111111-1111-1111-1114-111111111111")!
    static let listUUID5 = UUID(uuidString: "11111111-1111-1111-1115-111111111111")!
    
    static let list1 = ShoppingList(id: listUUID1, name: "Office", items: [
        ShoppingItem(order: 0, listID: listUUID1, name: "A4 Printer Paper", note: "500 sheets, for montly reports.", status: .pending, price: 5.99, quantity: 2, unit: ShoppingItemUnit(.piece)),
        ShoppingItem(order: 1, listID: listUUID1, name: "Blue Ballpoint Pens", note: "Medium tip, blue ink.", status: .pending, price: 0.49, quantity: 10, unit: ShoppingItemUnit(.piece)),
        ShoppingItem(order: 2, listID: listUUID1, name: "Sticky Notes", note: "75x75 mm, yellow, repositionable.", status: .purchased, price: 1.20, quantity: 3, unit: ShoppingItemUnit(.piece)),
        ShoppingItem(order: 3, listID: listUUID1, name: "Permanent Markers", note: "Black, waterproof ink.", status: .purchased, price: 0.89, quantity: 5, unit: ShoppingItemUnit(.piece)),
        ShoppingItem(order: 4, listID: listUUID1, name: "Whiteboard Cleaner Spray", note: "In bottle 250 ml, for conference room use.", status: .purchased, price: 4.50, quantity: 1, unit: ShoppingItemUnit(.piece)),
        ShoppingItem(order: 5, listID: listUUID1, name: "Highlighters (4 colors)", note: "Yellow, green, pink, orange.", status: .inactive, price: 3.50, quantity: 2, unit: ShoppingItemUnit(.piece)),
        ShoppingItem(order: 6, listID: listUUID1, name: "Envelopes (C5, self-seal)", note: "For mailing invoices.", status: .purchased, price: 0.07, quantity: 100, unit: ShoppingItemUnit(.piece)),
        ShoppingItem(order: 7, listID: listUUID1, name: "Correction Tape", note: "Better than fluid.", status: .pending, price: 2.30, quantity: 2, unit: ShoppingItemUnit(.piece)),
        ShoppingItem(order: 8, listID: listUUID1, name: "Office Scissors (21cm)", note: "Stainless steel, right-handed.", status: .pending, price: 3.80, quantity: 1, unit: ShoppingItemUnit(.piece)),
        ShoppingItem(order: 9, listID: listUUID1, name: "USB Flash Drive", note: "32 GB", status: .inactive, price: 6.99, quantity: 1, unit: ShoppingItemUnit(.piece)),
        ShoppingItem(order: 10, listID: listUUID1, name: "Binder Clips (25 mm)", note: "Black metal, medium size.", status: .pending, price: 0.15, quantity: 12, unit: ShoppingItemUnit(.piece)),
        ShoppingItem(order: 11, listID: listUUID1, name: "Desk Organizer", note: "Pen holder, tray, sticky note box.", status: .inactive, price: 9.99, quantity: 1, unit: ShoppingItemUnit(.piece))
    ], order: 0, icon: .paperclip, color: .indigo)
    
    static let list2 = ShoppingList(id: listUUID2, name: "Fruits & Vegetables", items: [
        ShoppingItem(order: 0, listID: listUUID2, name: "Bananas", note: "Ripe, medium size, for smoothies.", status: .pending, price: 0.35, quantity: 6, unit: ShoppingItemUnit(.piece)),
        ShoppingItem(order: 1, listID: listUUID2, name: "Apples (Gala)", note: "Sweet and crisp, lunch snacks.", status: .pending, price: 0.45, quantity: 5, unit: ShoppingItemUnit(.piece)),
        ShoppingItem(order: 2, listID: listUUID2, name: "Carrots", note: "Washed, medium size, for soup.", status: .purchased, price: 1.10, quantity: 1, unit: ShoppingItemUnit(.kilogram)),
        ShoppingItem(order: 3, listID: listUUID2, name: "Tomatoes", note: "Ripe, vine, for sandwiches.", status: .purchased, price: 2.30, quantity: 1, unit: ShoppingItemUnit(.kilogram)),
        ShoppingItem(order: 4, listID: listUUID2, name: "Spinach", note: "Fresh leaves, for salad.", status: .purchased, price: 1.75, quantity: 1, unit: ShoppingItemUnit(.piece)),
        ShoppingItem(order: 5, listID: listUUID2, name: "Avocados", note: "Ripe, ready to eat.", status: .inactive, price: 1.20, quantity: 2, unit: ShoppingItemUnit(.piece)),
        ShoppingItem(order: 6, listID: listUUID2, name: "Red Bell Peppers", note: "Crisp, for stir fry.", status: .purchased, price: 0.99, quantity: 3, unit: ShoppingItemUnit(.piece)),
        ShoppingItem(order: 7, listID: listUUID2, name: "Lemons", note: "Juicy, for tea and dressing.", status: .pending, price: 0.55, quantity: 4, unit: ShoppingItemUnit(.piece)),
        ShoppingItem(order: 8, listID: listUUID2, name: "Cucumbers", note: "Long, fresh, for sandwiches.", status: .pending, price: 0.85, quantity: 2, unit: ShoppingItemUnit(.piece)),
        ShoppingItem(order: 9, listID: listUUID2, name: "Grapes (Green)", note: "Seedless, for snacking.", status: .inactive, price: 3.50, quantity: 1, unit: ShoppingItemUnit(.kilogram)),
        ShoppingItem(order: 10, listID: listUUID2, name: "Onions (Yellow)", note: "For cooking, medium size.", status: .pending, price: 0.70, quantity: 1, unit: ShoppingItemUnit(.kilogram)),
        ShoppingItem(order: 11, listID: listUUID2, name: "Parsley", note: "Fresh bunch, for garnish.", status: .inactive, price: 0.99, quantity: 1, unit: ShoppingItemUnit(.piece))
    ], order: 1, icon: .flora, color: .green)
    
    static let list3 = ShoppingList(id: listUUID3, name: "Groceries", items: [
        ShoppingItem(order: 0, listID: listUUID3, name: "Whole Milk", note: "1 liter, full fat, for coffee and cereal.", status: .pending, price: 1.29, quantity: 2, unit: ShoppingItemUnit(.liter)),
        ShoppingItem(order: 1, listID: listUUID3, name: "Eggs (Free-range)", note: "Medium size, pack of 10.", status: .pending, price: 2.49, quantity: 1, unit: ShoppingItemUnit(.piece)),
        ShoppingItem(order: 2, listID: listUUID3, name: "Bread (Sourdough)", note: "Freshly baked, sliced.", status: .purchased, price: 3.10, quantity: 1, unit: ShoppingItemUnit(.piece)),
        ShoppingItem(order: 3, listID: listUUID3, name: "Butter", note: "Unsalted, for baking.", status: .purchased, price: 2.20, quantity: 1, unit: ShoppingItemUnit(.piece)),
        ShoppingItem(order: 4, listID: listUUID3, name: "Cheddar Cheese", note: "Mature, block, for sandwiches.", status: .purchased, price: 3.99, quantity: 1, unit: ShoppingItemUnit(.piece)),
        ShoppingItem(order: 5, listID: listUUID3, name: "Rice (Basmati)", note: "1 kg bag, for curry.", status: .inactive, price: 2.75, quantity: 1, unit: ShoppingItemUnit(.kilogram)),
        ShoppingItem(order: 6, listID: listUUID3, name: "Olive Oil", note: "Extra virgin, for salad dressing.", status: .purchased, price: 6.90, quantity: 1, unit: ShoppingItemUnit(.liter)),
        ShoppingItem(order: 7, listID: listUUID3, name: "Tofu", note: "Firm, 300g, for stir fry.", status: .pending, price: 2.80, quantity: 1, unit: ShoppingItemUnit(.piece)),
        ShoppingItem(order: 8, listID: listUUID3, name: "Yogurt (Natural)", note: "Plain, 400g cup.", status: .pending, price: 1.15, quantity: 2, unit: ShoppingItemUnit(.piece)),
        ShoppingItem(order: 9, listID: listUUID3, name: "Pasta (Penne)", note: "500g bag, for dinner.", status: .inactive, price: 1.25, quantity: 1, unit: ShoppingItemUnit(.piece)),
        ShoppingItem(order: 10, listID: listUUID3, name: "Tomato Sauce", note: "Glass jar, for pasta.", status: .pending, price: 1.99, quantity: 1, unit: ShoppingItemUnit(.piece)),
        ShoppingItem(order: 11, listID: listUUID3, name: "Canned Chickpeas", note: "400g, for hummus and salads.", status: .inactive, price: 0.89, quantity: 2, unit: ShoppingItemUnit(.piece))
    ], order: 2, icon: .cart, color: .red)
    
    static let list4 = ShoppingList(id: listUUID4, name: "Tools & Hardware", items: [
        ShoppingItem(order: 0, listID: listUUID4, name: "Hammer", note: "500g, fiberglass handle.", status: .purchased, price: 14.99, quantity: 1, unit: ShoppingItemUnit(.piece)),
        ShoppingItem(order: 1, listID: listUUID4, name: "Screwdriver Set", note: "Flat & Phillips, 6-piece set.", status: .pending, price: 19.99, quantity: 1, unit: ShoppingItemUnit(.piece)),
        ShoppingItem(order: 2, listID: listUUID4, name: "Screws 4×40mm", note: "Zinc-coated wood screws, 100 pcs.", status: .pending, price: 4.99, quantity: 1, unit: ShoppingItemUnit(.piece)),
        ShoppingItem(order: 3, listID: listUUID4, name: "Nails 2.5×60mm", note: "Steel, smooth shank, 200 pcs.", status: .purchased, price: 3.50, quantity: 1, unit: ShoppingItemUnit(.piece)),
        ShoppingItem(order: 4, listID: listUUID4, name: "Washers M8", note: "Stainless steel, pack of 50.", status: .pending, price: 2.99, quantity: 1, unit: ShoppingItemUnit(.piece)),
        ShoppingItem(order: 5, listID: listUUID4, name: "Hex Nuts M6", note: "Galvanized steel, DIN 934, 100 pcs.", status: .pending, price: 3.99, quantity: 1, unit: ShoppingItemUnit(.piece)),
        ShoppingItem(order: 6, listID: listUUID4, name: "Drill Bit Set", note: "1–10mm, for metal and wood, 13 pcs.", status: .inactive, price: 24.99, quantity: 1, unit: ShoppingItemUnit(.piece)),
        ShoppingItem(order: 7, listID: listUUID4, name: "Adjustable Wrench", note: "150mm, chrome finish.", status: .inactive, price: 9.99, quantity: 1, unit: ShoppingItemUnit(.piece)),
        ShoppingItem(order: 8, listID: listUUID4, name: "Cable Ties 200mm", note: "Black nylon, 100 pcs.", status: .purchased, price: 5.49, quantity: 1, unit: ShoppingItemUnit(.piece)),
        ShoppingItem(order: 9, listID: listUUID4, name: "Plastic Wall Plugs Ø8mm", note: "For concrete and brick, 50 pcs.", status: .pending, price: 3.99, quantity: 1, unit: ShoppingItemUnit(.piece)),
        ShoppingItem(order: 10, listID: listUUID4, name: "Measuring Tape", note: "5 meters, retractable.", status: .purchased, price: 6.99, quantity: 1, unit: ShoppingItemUnit(.piece)),
        ShoppingItem(order: 11, listID: listUUID4, name: "Sanding Paper P120", note: "230×280mm, medium grit, pack of 10.", status: .inactive, price: 3.49, quantity: 1, unit: ShoppingItemUnit(.piece))
    ], order: 3, icon: .tool, color: .gray)
    
    static let list5 = ShoppingList(id: listUUID5, name: "Clothing Store", items: [
        ShoppingItem(order: 0, listID: listUUID5, name: "Basic T-Shirt", note: "White, 100% cotton, size M.", status: .pending, price: 8.99, quantity: 2, unit: ShoppingItemUnit(.piece)),
        ShoppingItem(order: 1, listID: listUUID5, name: "Denim Jacket", note: "Classic fit, blue, size L.", status: .purchased, price: 59.90, quantity: 1, unit: ShoppingItemUnit(.piece)),
        ShoppingItem(order: 2, listID: listUUID5, name: "Chinos", note: "Beige, size 34.", status: .pending, price: 39.99, quantity: 1, unit: ShoppingItemUnit(.piece)),
        ShoppingItem(order: 3, listID: listUUID5, name: "Casual Shoes", note: "Size 42, grey suede.", status: .inactive, price: 64.50, quantity: 1, unit: ShoppingItemUnit(string: "pair")),
        ShoppingItem(order: 4, listID: listUUID5, name: "Sports Socks (3-pack)", note: "White cotton, breathable.", status: .purchased, price: 6.75, quantity: 1, unit: ShoppingItemUnit(string: "set")),
        ShoppingItem(order: 5, listID: listUUID5, name: "Wool Scarf", note: "Dark green, 180 cm.", status: .pending, price: 17.00, quantity: 1, unit: ShoppingItemUnit(.piece)),
        ShoppingItem(order: 6, listID: listUUID5, name: "Leather Gloves", note: "Black, size M.", status: .pending, price: 25.00, quantity: 1, unit: ShoppingItemUnit(string: "pair"))
    ], order: 4, icon: .person, color: .magenta)

    
    static let allLists: [ShoppingList] = [list1, list2, list3, list4, list5]
    
    static let deletedItems: [ShoppingItem] = [
        ShoppingItem(order: 0, listID: nil, name: "Notebook (A5)", note: "Lined, 100 pages, for meeting notes.", status: .purchased, price: 4.20, quantity: 2, unit: ShoppingItemUnit(.piece), deletedAt: Calendar.current.date(byAdding: .day, value: -1, to: Date())),
        ShoppingItem(order: 0, listID: nil, name: "Toothpaste", note: "Whitening, 75ml tube.", status: .pending, price: 2.99, quantity: 1, unit: ShoppingItemUnit(.piece), deletedAt: Calendar.current.date(byAdding: .day, value: -4, to: Date())),
        ShoppingItem(order: 0, listID: nil, name: "Laundry Detergent", note: "For color clothes, 2.1L.", status: .inactive, price: 12.49, quantity: 1, unit: ShoppingItemUnit(.liter), deletedAt: Calendar.current.date(byAdding: .day, value: -7, to: Date())),
        ShoppingItem(order: 0, listID: nil, name: "Olive Oil (Extra Virgin)", note: "Cold pressed, 500ml bottle.", status: .purchased, price: 7.95, quantity: 1, unit: ShoppingItemUnit(.liter), deletedAt: Calendar.current.date(byAdding: .day, value: -9, to: Date())),
        ShoppingItem(order: 0, listID: nil, name: "Paper Towels", note: "2 rolls, strong absorbency.", status: .purchased, price: 5.20, quantity: 2, unit: ShoppingItemUnit(.piece), deletedAt: Calendar.current.date(byAdding: .day, value: -11, to: Date())),
        ShoppingItem(order: 0, listID: nil, name: "Hand Soap", note: "Lavender scent, 300ml pump bottle.", status: .pending, price: 3.10, quantity: 1, unit: ShoppingItemUnit(.piece), deletedAt: Calendar.current.date(byAdding: .day, value: -13, to: Date())),
        ShoppingItem(order: 0, listID: nil, name: "LED Bulbs (E27)", note: "Warm white, 10W, energy saving.", status: .inactive, price: 8.99, quantity: 4, unit: ShoppingItemUnit(.piece), deletedAt: Calendar.current.date(byAdding: .day, value: -17, to: Date())),
        ShoppingItem(order: 0, listID: nil, name: "Garden Gloves", note: "Waterproof, size M.", status: .pending, price: 6.75, quantity: 1, unit: ShoppingItemUnit(.piece), deletedAt: Calendar.current.date(byAdding: .day, value: -21, to: Date())),
        ShoppingItem(order: 0, listID: nil, name: "Oat Milk", note: "Barista edition, 1L carton.", status: .purchased, price: 3.30, quantity: 2, unit: ShoppingItemUnit(.liter), deletedAt: Calendar.current.date(byAdding: .day, value: -26, to: Date())),
        ShoppingItem(order: 0, listID: nil, name: "Ziplock Bags", note: "Medium size, 30 pcs, freezer safe.", status: .inactive, price: 4.50, quantity: 1, unit: ShoppingItemUnit(.piece), deletedAt: Calendar.current.date(byAdding: .day, value: -29, to: Date()))
    ]
}

// MARK: Mock loyalty cards

extension MockDataRepository {
    static let cardUUID1 = UUID(uuidString: "22222222-2222-2222-2221-222222222222")!
    static let cardUUID2 = UUID(uuidString: "22222222-2222-2222-2222-222222222222")!
    static let cardUUID3 = UUID(uuidString: "22222222-2222-2222-2223-222222222222")!
    static let cardUUID4 = UUID(uuidString: "22222222-2222-2222-2224-222222222222")!
    static let cardUUID5 = UUID(uuidString: "22222222-2222-2222-2225-222222222222")!
    static let cardUUID6 = UUID(uuidString: "22222222-2222-2222-2226-222222222222")!
    static let cardUUID7 = UUID(uuidString: "22222222-2222-2222-2227-222222222222")!
    
    static let card1 = LoyaltyCard(id: cardUUID1, name: "MorphStore", imageID: "22222222-2222-2222-2221-222222222221", order: 0)
    
    static let card2 = LoyaltyCard(id: cardUUID2, name: "EcoMart", imageID: "22222222-2222-2222-2222-222222222222", order: 1)
    
    static let card3 = LoyaltyCard(id: cardUUID3, name: "AmiShop", imageID: "22222222-2222-2222-2223-222222222223", order: 2)
    
    static let card4 = LoyaltyCard(id: cardUUID4, name: "UrbanWear", imageID: "22222222-2222-2222-2224-222222222224", order: 3)
    
    static let card5 = LoyaltyCard(id: cardUUID5, name: "Fresh Basket", imageID: "22222222-2222-2222-2225-222222222225", order: 4)
    
    static let card6 = LoyaltyCard(id: cardUUID6, name: "CasaDecor", imageID: "22222222-2222-2222-2226-222222222226", order: 5)
    
    static let card7 = LoyaltyCard(id: cardUUID7, name: "TechNest", imageID: "22222222-2222-2222-2227-222222222227", order: 6)
    
    static let allCards: [LoyaltyCard] = [card1, card2, card3, card4, card5, card6, card7]
    
    static let allCardImageFileNames: [String] = ["MorphStore_card", "EcoMart_card", "AmiShop_card", "UrbanWear_card", "FreshBasket_card", "CasaDecor_card", "TechNest_card"]
}
