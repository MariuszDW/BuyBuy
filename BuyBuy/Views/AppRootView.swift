//
//  AppRootView.swift
//  BuyBuy
//
//  Created by MDW on 14/05/2025.
//

import SwiftUI

struct AppRootView: View {
    @ObservedObject var coordinator: AppCoordinator
    @ObservedObject var sheetPresenter: SheetPresenter
    
    init(coordinator: AppCoordinator) {
        self.coordinator = coordinator
        self.sheetPresenter = coordinator.sheetPresenter
    }
    
    var body: some View {
        NavigationStack(path: $coordinator.navigationPath) {
            coordinator.view(for: .shoppingLists)
                .navigationDestination(for: AppRoute.self) { route in
                    coordinator.view(for: route)
                }
                .fullScreenCover(
                    isPresented: Binding(
                        get: { !sheetPresenter.stack.isEmpty },
                        set: { isPresented in
                            if !isPresented {
                                sheetPresenter.dismiss(at: 0)
                            }
                        }
                    )
                ) {
                    nestedSheet(at: 0)
                }
        }
    }
    
    private func nestedSheet(at index: Int) -> AnyView {
        guard sheetPresenter.hasSheet(at: index) else {
            return AnyView(EmptyView())
        }
        
        let presentedSheet = sheetPresenter.stack[index]
        let view = coordinator.sheetView(for: presentedSheet.route)
        
        return AnyView(
            NavigationStack {
                view
                    .fullScreenCover(
                        isPresented: Binding(
                            get: { sheetPresenter.hasSheet(after: index) },
                            set: { isPresented in
                                if !isPresented {
                                    sheetPresenter.dismiss(after: index)
                                }
                            }
                        )
                    ) {
                        nestedSheet(at: index + 1)
                    }
            }
        )
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
