//
//  Version.swift
//  BuyBuy
//
//  Created by MDW on 07/08/2025.
//

import Foundation

struct Version: Comparable {
    let components: [Int]

    init(_ string: String) {
        self.components = string
            .split(separator: ".")
            .map { Int($0) ?? 0 }
    }

    static func < (lhs: Version, rhs: Version) -> Bool {
        let maxLength = max(lhs.components.count, rhs.components.count)
        let left = lhs.components + Array(repeating: 0, count: maxLength - lhs.components.count)
        let right = rhs.components + Array(repeating: 0, count: maxLength - rhs.components.count)
        return left.lexicographicallyPrecedes(right)
    }
}
