//
//  DynamicViewContent+Extensions.swift
//  BuyBuy
//
//  Created by MDW on 14/11/2026.
//

import Foundation
import SwiftUI

extension DynamicViewContent {
    /// Applies `onMove` only when the app is not running on macOS ('Designed for iPad').
    @ViewBuilder
    func onMoveIfAvailable(perform action: @escaping (IndexSet, Int) -> Void) -> some View {
        if ProcessInfo.processInfo.isiOSAppOnMac {
            self
        } else {
            self.onMove(perform: action)
        }
    }
}
