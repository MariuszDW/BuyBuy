//
//  NavigationPath+Extensions.swift
//  BuyBuy
//
//  Created by MDW on 28/11/2025.
//

import SwiftUI

extension NavigationPath {
    /// Removes all elements (mutating).
    mutating func reset() {
        //if !self.isEmpty {
        //    self.removeLast(self.count)
        //}
        self = NavigationPath()
    }

    /// Checks if the last element of the path matches the target.
    func isLast(_ route: AppRoute) -> Bool {
        guard self.count > 0 else { return false }

        var test = self
        test.removeLast()
        test.append(route)

        return test == self
    }
}
