//
//  MockDataRepository.swift
//  BuyBuy
//
//  Created by MDW on 20/05/2025.
//

import Foundation

final class MockDataRepository: DataRepositoryProtocol {
    static let uuid1 = UUID(uuidString: "11111111-1111-1111-1111-111111111111")!
    static let uuid2 = UUID(uuidString: "22222222-2222-2222-2222-222222222222")!
    static let uuid3 = UUID(uuidString: "33333333-3333-3333-3333-333333333333")!
    static let uuid4 = UUID(uuidString: "44444444-4444-4444-4444-444444444444")!
    static let uuid5 = UUID(uuidString: "55555555-5555-5555-5555-555555555555")!

    static let list1 = ShoppingList(id: uuid1, name: "Grocery Store", items: [
        ShoppingItem(order: 0, listID: uuid1, name: "Milk", note: "Pilos 3.2%, 1 L", status: .pending, price: 3.79, quantity: 2, unit: ShoppingItemUnit(.liter)),
        ShoppingItem(order: 1, listID: uuid1, name: "Bread", status: .pending, price: 4.79, quantity: 2, unit: ShoppingItemUnit(.piece)),
        ShoppingItem(order: 2, listID: uuid1, name: "Eggs", note: "Box 12x", status: .inactive, quantity: 1),
        ShoppingItem(order: 3, listID: uuid1, name: "Apples", note: "2 kg (in promotion)", status: .purchased, quantity: 2.5, unit: ShoppingItemUnit(.kilogram)),
        ShoppingItem(order: 4, listID: uuid1, name: "Chicken", status: .purchased),
        ShoppingItem(order: 5, listID: uuid1, name: "Butter", note: "As cheap as possible.", status: .purchased, quantity: 1),
        ShoppingItem(order: 6, listID: uuid1, name: "Yogurt", note: "Natural, 500 g", status: .inactive, price: 1.79, quantity: 3)
    ], order: 0, icon: .cart, color: .orange)

    static let list2 = ShoppingList(id: uuid2, name: "Hardware Store", items: [
        ShoppingItem(order: 0, listID: uuid2, name: "Screws", status: .purchased),
        ShoppingItem(order: 1, listID: uuid2, name: "Hammer", note: "As big as possible", status: .pending, quantity: 1),
        ShoppingItem(order: 2, listID: uuid2, name: "Paint", status: .inactive),
        ShoppingItem(order: 3, listID: uuid2, name: "Wrench", status: .purchased),
        ShoppingItem(order: 4, listID: uuid2, name: "Drill", status: .pending),
        ShoppingItem(order: 5, listID: uuid2, name: "Tape Measure", status: .purchased),
        ShoppingItem(order: 6, listID: uuid2, name: "Ladder", status: .inactive),
        ShoppingItem(order: 7, listID: uuid2, name: "Sandpaper", status: .pending)
    ], order: 1, icon: .house, color: .brown)

    static let list3 = ShoppingList(id: uuid3, name: "Sports Equipment", items: [
        ShoppingItem(order: 0, listID: uuid3, name: "Football", status: .pending),
        ShoppingItem(order: 1, listID: uuid3, name: "Tennis Racket", status: .purchased),
        ShoppingItem(order: 2, listID: uuid3, name: "Running Shoes", status: .purchased),
        ShoppingItem(order: 3, listID: uuid3, name: "Yoga Mat", status: .inactive),
        ShoppingItem(order: 4, listID: uuid3, name: "Water Bottle", status: .pending),
        ShoppingItem(order: 5, listID: uuid3, name: "Sweatband", status: .inactive),
        ShoppingItem(order: 6, listID: uuid3, name: "Gym Bag", status: .pending),
        ShoppingItem(order: 7, listID: uuid3, name: "Basketball", status: .purchased),
        ShoppingItem(order: 8, listID: uuid3, name: "Swim Goggles", status: .purchased)
    ], order: 2, icon: .sport, color: .blue)

    static let list4 = ShoppingList(id: uuid4, name: "Pet Supplies", items: [
        ShoppingItem(order: 0, listID: uuid4, name: "Cat Food", note: "The best", status: .purchased, quantity: 6),
        ShoppingItem(order: 1, listID: uuid4, name: "Dog Leash", status: .inactive),
        ShoppingItem(order: 2, listID: uuid4, name: "Bird Seed", status: .pending),
        ShoppingItem(order: 3, listID: uuid4, name: "Pet Shampoo", status: .purchased),
        ShoppingItem(order: 4, listID: uuid4, name: "Dog Treats", status: .pending),
        ShoppingItem(order: 5, listID: uuid4, name: "Cat Litter", status: .inactive),
        ShoppingItem(order: 6, listID: uuid4, name: "Fish Tank Filter", status: .purchased)
    ], order: 3, icon: .cat, color: .pink)

    static let list5 = ShoppingList(id: uuid5, name: "Empty", items: [], order: 4, icon: .questionmark, color: .cyan)

    static let allLists: [ShoppingList] = [list1, list2, list3, list4, list5]

    let shoppingLists: [ShoppingList]

    init(lists: [ShoppingList] = allLists) {
        self.shoppingLists = lists
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

    func fetchAllLoyaltyCards() async throws -> [LoyaltyCard] {
        return [] // TODO: implement...
    }

    func fetchLoyaltyCard(with id: UUID) async throws -> LoyaltyCard? {
        return nil // TODO: implement...
    }

    func addOrUpdateLoyaltyCard(_ card: LoyaltyCard) async throws {}

    func deleteLoyaltyCard(with id: UUID) async throws {}

    // MARK: - Loyalty images

    func fetchAllCardImageIDs() async throws -> Set<String> {
        return Set<String>()
    }
}
