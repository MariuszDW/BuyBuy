//
//  MockDataRepository.swift
//  BuyBuy
//
//  Created by MDW on 20/05/2025.
//

import Foundation

final class MockDataRepository: DataRepositoryProtocol {
    let shoppingLists: [ShoppingList]
    let loyaltyCards: [LoyaltyCard]

    init(lists: [ShoppingList] = MockDataRepository.allLists,
         cards: [LoyaltyCard] = MockDataRepository.allCards) {
        self.shoppingLists = lists
        self.loyaltyCards = cards
    }

    // MARK: - Lists

    func fetchAllLists() async throws -> [ShoppingList] {
        return shoppingLists
    }

    func fetchList(with id: UUID) async throws -> ShoppingList? {
        return shoppingLists.first(where: { $0.id == id })
    }

    func addOrUpdateList(_ list: ShoppingList) async throws {}

    func deleteList(with id: UUID) async throws {}

    func deleteLists(with ids: [UUID]) async throws {}

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

    func addOrUpdateItem(_ item: ShoppingItem) async throws {}

    func deleteItem(with id: UUID) async throws {}

    func deleteItems(with ids: [UUID]) async throws {}

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

    // MARK: - Loyalty card images

    func fetchAllLoyaltyCardImageIDs() async throws -> Set<String> {
        return Set<String>()
    }
}

// MARK: Mock shopping lists

extension MockDataRepository {
    static let listUUID1 = UUID(uuidString: "11111111-1111-1111-1111-111111111111")!
    static let listUUID2 = UUID(uuidString: "11111111-1111-1111-1111-111111111112")!
    static let listUUID3 = UUID(uuidString: "11111111-1111-1111-1111-111111111113")!
    static let listUUID4 = UUID(uuidString: "11111111-1111-1111-1111-111111111114")!
    static let listUUID5 = UUID(uuidString: "11111111-1111-1111-1111-111111111115")!
    
    static let list1 = ShoppingList(id: listUUID1, name: "Grocery Store", items: [
        ShoppingItem(order: 0, listID: listUUID1, name: "Milk", note: "Pilos 3.2%, 1 L", status: .pending, price: 3.79, quantity: 2, unit: ShoppingItemUnit(.liter)),
        ShoppingItem(order: 1, listID: listUUID1, name: "Bread", status: .pending, price: 4.79, quantity: 2, unit: ShoppingItemUnit(.piece)),
        ShoppingItem(order: 2, listID: listUUID1, name: "Eggs", note: "Box 12x", status: .inactive, quantity: 1),
        ShoppingItem(order: 3, listID: listUUID1, name: "Apples", note: "2 kg (in promotion)", status: .purchased, quantity: 2.5, unit: ShoppingItemUnit(.kilogram)),
        ShoppingItem(order: 4, listID: listUUID1, name: "Chicken", status: .purchased),
        ShoppingItem(order: 5, listID: listUUID1, name: "Butter", note: "As cheap as possible.", status: .purchased, price: 4.79, quantity: 1),
        ShoppingItem(order: 6, listID: listUUID1, name: "Yogurt", note: "Natural, 500 g", status: .inactive, price: 1.79, quantity: 3)
    ], order: 0, icon: .cart, color: .orange)
    
    static let list2 = ShoppingList(id: listUUID2, name: "Hardware Store", items: [
        ShoppingItem(order: 0, listID: listUUID2, name: "Screws", status: .purchased),
        ShoppingItem(order: 1, listID: listUUID2, name: "Hammer", note: "As big as possible", status: .pending, quantity: 1),
        ShoppingItem(order: 2, listID: listUUID2, name: "Paint", status: .inactive),
        ShoppingItem(order: 3, listID: listUUID2, name: "Wrench", status: .purchased),
        ShoppingItem(order: 4, listID: listUUID2, name: "Drill", status: .pending),
        ShoppingItem(order: 5, listID: listUUID2, name: "Tape Measure", status: .purchased),
        ShoppingItem(order: 6, listID: listUUID2, name: "Ladder", status: .inactive),
        ShoppingItem(order: 7, listID: listUUID2, name: "Sandpaper", status: .pending)
    ], order: 1, icon: .house, color: .brown)
    
    static let list3 = ShoppingList(id: listUUID3, name: "Sports Equipment", items: [
        ShoppingItem(order: 0, listID: listUUID3, name: "Football", status: .pending),
        ShoppingItem(order: 1, listID: listUUID3, name: "Tennis Racket", status: .purchased),
        ShoppingItem(order: 2, listID: listUUID3, name: "Running Shoes", status: .purchased),
        ShoppingItem(order: 3, listID: listUUID3, name: "Yoga Mat", status: .inactive),
        ShoppingItem(order: 4, listID: listUUID3, name: "Water Bottle", status: .pending),
        ShoppingItem(order: 5, listID: listUUID3, name: "Sweatband", status: .inactive),
        ShoppingItem(order: 6, listID: listUUID3, name: "Gym Bag", status: .pending),
        ShoppingItem(order: 7, listID: listUUID3, name: "Basketball", status: .purchased),
        ShoppingItem(order: 8, listID: listUUID3, name: "Swim Goggles", status: .purchased)
    ], order: 2, icon: .sport, color: .blue)
    
    static let list4 = ShoppingList(id: listUUID4, name: "Pet Supplies", items: [
        ShoppingItem(order: 0, listID: listUUID4, name: "Cat Food", note: "The best", status: .purchased, quantity: 6),
        ShoppingItem(order: 1, listID: listUUID4, name: "Dog Leash", status: .inactive),
        ShoppingItem(order: 2, listID: listUUID4, name: "Bird Seed", status: .pending),
        ShoppingItem(order: 3, listID: listUUID4, name: "Pet Shampoo", status: .purchased),
        ShoppingItem(order: 4, listID: listUUID4, name: "Dog Treats", status: .pending),
        ShoppingItem(order: 5, listID: listUUID4, name: "Cat Litter", status: .inactive),
        ShoppingItem(order: 6, listID: listUUID4, name: "Fish Tank Filter", status: .purchased)
    ], order: 3, icon: .cat, color: .pink)
    
    static let list5 = ShoppingList(id: listUUID5, name: "Empty", items: [], order: 4, icon: .questionmark, color: .cyan)
    
    static let allLists: [ShoppingList] = [list1, list2, list3, list4, list5]
}

// MARK: Mock loyalty cards

extension MockDataRepository {
    static let cardUUID1 = UUID(uuidString: "22222222-2222-2222-2222-222222222221")!
    static let cardUUID2 = UUID(uuidString: "22222222-2222-2222-2222-222222222222")!
    static let cardUUID3 = UUID(uuidString: "22222222-2222-2222-2222-222222222223")!
    static let cardUUID4 = UUID(uuidString: "22222222-2222-2222-2222-222222222224")!
    static let cardUUID5 = UUID(uuidString: "22222222-2222-2222-2222-222222222225")!
    static let cardUUID6 = UUID(uuidString: "22222222-2222-2222-2222-222222222226")!
    static let cardUUID7 = UUID(uuidString: "22222222-2222-2222-2222-222222222227")!
    
    static let card1 = LoyaltyCard(id: cardUUID1, name: "Lidl", imageID: nil, order: 0)
    
    static let card2 = LoyaltyCard(id: cardUUID2, name: "Biedronka", imageID: nil, order: 1)
    
    static let card3 = LoyaltyCard(id: cardUUID3, name: "Auchan", imageID: nil, order: 2)
    
    static let card4 = LoyaltyCard(id: cardUUID4, name: "BuyBuy Super Shop", imageID: nil, order: 3)
    
    static let card5 = LoyaltyCard(id: cardUUID5, name: "Carrefour", imageID: nil, order: 4)
    
    static let card6 = LoyaltyCard(id: cardUUID6, name: "Kaufland", imageID: nil, order: 5)
    
    static let card7 = LoyaltyCard(id: cardUUID7, name: "Castorama", imageID: nil, order: 6)
    
    static let allCards: [LoyaltyCard] = [card1, card2, card3, card4, card5, card6, card7]
}
