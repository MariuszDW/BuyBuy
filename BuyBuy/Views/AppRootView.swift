//
//  AppRootView.swift
//  BuyBuy
//
//  Created by MDW on 14/05/2025.
//

import SwiftUI

struct AppRootView: View {
    @ObservedObject var coordinator: AppCoordinator
    
    var body: some View {
        NavigationStack(path: $coordinator.navigationPath) {
            coordinator.view(for: .shoppingLists)
                .navigationDestination(for: AppRoute.self) { route in
                    coordinator.view(for: route)
                }
                .sheet(item: $coordinator.sheet, onDismiss: {
                    coordinator.onSheetDismissed?()
                    coordinator.onSheetDismissed = nil
                }) { sheet in
                    NavigationStack {
                        coordinator.sheetView(for: sheet)
                    }
                }
        }
    }
}

// MARK: - Preview

#Preview("Light") {
    AppRootView(coordinator: AppCoordinator(dependencies: AppDependencies()))
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    AppRootView(coordinator: AppCoordinator(dependencies: AppDependencies()))
        .preferredColorScheme(.dark)
}
