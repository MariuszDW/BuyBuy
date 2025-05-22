//
//  MockShoppingListsRepository.swift
//  BuyBuy
//
//  Created by MDW on 20/05/2025.
//

import Foundation

final class MockShoppingListsRepository: ShoppingListsRepositoryProtocol {
    static let uuid1 = UUID(uuidString: "11111111-1111-1111-1111-111111111111")!
    static let uuid2 = UUID(uuidString: "22222222-2222-2222-2222-222222222222")!
    static let uuid3 = UUID(uuidString: "33333333-3333-3333-3333-333333333333")!
    static let uuid4 = UUID(uuidString: "44444444-4444-4444-4444-444444444444")!
    
    static let list1 = ShoppingList(id: uuid1, name: "Grocery Store", items: [
        ShoppingItem(order: 0, listID: uuid1, name: "Milk", status: .pending),
        ShoppingItem(order: 1, listID: uuid1, name: "Bread", status: .purchased),
        ShoppingItem(order: 2, listID: uuid1, name: "Eggs", status: .inactive),
        ShoppingItem(order: 3, listID: uuid1, name: "Apples", status: .pending),
        ShoppingItem(order: 4, listID: uuid1, name: "Chicken", status: .purchased),
        ShoppingItem(order: 5, listID: uuid1, name: "Butter", status: .purchased),
        ShoppingItem(order: 6, listID: uuid1, name: "Yogurt", status: .inactive)
    ], order: 0, icon: .cart, color: .orange)
    
    static let list2 = ShoppingList(id: uuid2, name: "Hardware Store", items: [
        ShoppingItem(order: 0, listID: uuid2, name: "Screws", status: .purchased),
        ShoppingItem(order: 1, listID: uuid2, name: "Hammer", status: .pending),
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
    ], order: 2, icon: .run, color: .blue)
    
    static let list4 = ShoppingList(id: uuid4, name: "Pet Supplies", items: [
        ShoppingItem(order: 0, listID: uuid4, name: "Cat Food", status: .purchased),
        ShoppingItem(order: 1, listID: uuid4, name: "Dog Leash", status: .inactive),
        ShoppingItem(order: 2, listID: uuid4, name: "Bird Seed", status: .pending),
        ShoppingItem(order: 3, listID: uuid4, name: "Pet Shampoo", status: .purchased),
        ShoppingItem(order: 4, listID: uuid4, name: "Dog Treats", status: .pending),
        ShoppingItem(order: 5, listID: uuid4, name: "Cat Litter", status: .inactive),
        ShoppingItem(order: 6, listID: uuid4, name: "Fish Tank Filter", status: .purchased)
    ], order: 3, icon: .cat, color: .pink)
    
    func fetchAllLists() async throws -> [ShoppingList] {
        return [Self.list1, Self.list2, Self.list3, Self.list4]
    }
    
    func fetchList(with id: UUID) async throws -> ShoppingList? {
        Self.list1
    }
    
    func addList(_ list: ShoppingList) async throws {}
    
    func updateList(_ list: ShoppingList) async throws {}
    
    func deleteList(with id: UUID) async throws {}
    
    func deleteLists(with ids: [UUID]) async throws {}
    
    func fetchItems(for listID: UUID) async throws -> [ShoppingItem] {
        return Self.list1.items
    }
    
    func addItem(_ item: ShoppingItem) async throws {}
    
    func updateItem(_ item: ShoppingItem) async throws {}
    
    func deleteItem(_ item: ShoppingItem) async throws {}
}
