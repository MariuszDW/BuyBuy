//
//  ShoppingListRepository.swift
//  BuyBuy
//
//  Created by MDW on 15/05/2025.
//

import Foundation

final class ShoppingListRepository: ShoppingListRepositoryProtocol {

    private var sampleData: [ShoppingList] = [
        ShoppingList(
            id: UUID(uuidString: "11111111-1111-1111-1111-111111111111")!,
            name: "Supermarket",
            items: [
                ShoppingItem(id: UUID(), name: "Milk", status: .active),
                ShoppingItem(id: UUID(), name: "Bread", status: .done),
                ShoppingItem(id: UUID(), name: "Eggs", status: .inactive)
            ]
        ),
        ShoppingList(
            id: UUID(uuidString: "22222222-2222-2222-2222-222222222222")!,
            name: "Hardware Store",
            items: [
                ShoppingItem(id: UUID(), name: "Nails", status: .active),
                ShoppingItem(id: UUID(), name: "Hammer", status: .done)
            ]
        )
    ]

    func fetchList(by id: UUID) -> ShoppingList? {
        sampleData.first { $0.id == id }
    }

    func fetchAllLists() -> [ShoppingList] {
        sampleData
    }
}
