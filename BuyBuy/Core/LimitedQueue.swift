//
//  LimitedQueue.swift
//  BuyBuy
//
//  Created by MDW on 18/06/2025.
//

import Foundation

struct LimitedQueue<T> {
    private var elements: [T] = []
    private let maxSize: Int

    init(maxSize: Int) {
        self.maxSize = maxSize
    }

    mutating func enqueue(_ element: T) {
        elements.append(element)
        if elements.count > maxSize {
            elements.removeFirst()
        }
    }

    func contains(where predicate: (T) -> Bool) -> Bool {
        return elements.contains(where: predicate)
    }
}
