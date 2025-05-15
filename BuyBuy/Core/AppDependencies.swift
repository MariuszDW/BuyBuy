//
//  AppDependencies.swift
//  BuyBuy
//
//  Created by MDW on 15/05/2025.
//

import SwiftUI

final class AppDependencies: ObservableObject {
    @Published var designSystem: DesignSystem

    init(designSystem: DesignSystem = DesignSystem()) {
        self.designSystem = designSystem
    }
}
