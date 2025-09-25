//
//  AppRootView.swift
//  BuyBuy
//
//  Created by MDW on 14/05/2025.
//

import SwiftUI

struct AppRootView: View {
    @Environment(\.scenePhase) private var scenePhase
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
                .applyPresentationStyle(
                    style: sheetPresenter.stack.first?.displayStyle ?? .fullScreen,
                    isPresented: Binding(
                        get: { !sheetPresenter.stack.isEmpty },
                        set: { isPresented in
                            if !isPresented {
                                sheetPresenter.dismiss(at: 0)
                            }
                        }
                    ),
                    content: {
                        nestedSheet(at: 0)
                    }
                )
        }
        .task {
            await coordinator.onAppStart()
        }
        .onChange(of: scenePhase) { newPhase in
            switch newPhase {
            case .active:
                coordinator.onAppActive()
            case .inactive:
                coordinator.onAppInactive()
            default:
                break
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
                    .applyPresentationStyle(
                        style: presentedSheet.displayStyle,
                        isPresented: Binding(
                            get: { sheetPresenter.hasSheet(after: index) },
                            set: { isPresented in
                                if !isPresented {
                                    sheetPresenter.dismiss(after: index)
                                }
                            }
                        ),
                        content: {
                            nestedSheet(at: index + 1)
                        }
                    )
            }
        )
    }
}

private extension View {
    func applyPresentationStyle<Content: View>(
        style: SheetDisplayStyle,
        isPresented: Binding<Bool>,
        content: @escaping () -> Content
    ) -> some View {
        switch style {
        case .sheet:
            return AnyView(self.sheet(isPresented: isPresented, content: content))
        case .fullScreen:
            return AnyView(self.fullScreenCover(isPresented: isPresented, content: content))
        }
    }
}

// MARK: - Preview

#Preview("Light") {
    let preferences = MockAppPreferences()
    let coordinator = AppCoordinator(preferences: preferences)
    AppRootView(coordinator: coordinator)
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    let preferences = MockAppPreferences()
    let coordinator = AppCoordinator(preferences: preferences)
    AppRootView(coordinator: coordinator)
        .preferredColorScheme(.dark)
}
