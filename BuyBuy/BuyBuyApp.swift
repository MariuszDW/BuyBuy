//
//  BuyBuyApp.swift
//  BuyBuy
//
//  Created by MDW on 14/05/2025.
//

import SwiftUI

@main
struct BuyBuyApp: App {
    @StateObject var dependencies = AppDependencies()

    var body: some Scene {
        WindowGroup {
            AppRootView()
                .environmentObject(dependencies)
        }
    }
}
