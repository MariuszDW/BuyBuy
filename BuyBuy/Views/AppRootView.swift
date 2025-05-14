//
//  AppRootView.swift
//  BuyBuy
//
//  Created by MDW on 14/05/2025.
//

import SwiftUI

struct AppRootView: View {
    @StateObject var coordinator = AppCoordinator()

    var body: some View {
        NavigationStack(path: $coordinator.navigationPath) {
            HomeView(viewModel: HomeViewModel(coordinator: coordinator))
                .navigationDestination(for: AppRoute.self) { route in
                    coordinator.view(for: route)
                }
        }
    }
}

struct AppRootView_Previews: PreviewProvider {
    static var previews: some View {
        AppRootView()
            .preferredColorScheme(.light)

        AppRootView()
            .preferredColorScheme(.dark)
    }
}
