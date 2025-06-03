//
//  SheetPresenter.swift
//  BuyBuy
//
//  Created by MDW on 03/06/2025.
//

import Foundation

final class SheetPresenter: ObservableObject {
    struct PresentedSheet: Identifiable, Equatable {
        let route: SheetRoute
        let onDismiss: (() -> Void)?
        var id: String { route.id }

        static func == (lhs: PresentedSheet, rhs: PresentedSheet) -> Bool {
            lhs.id == rhs.id
        }
    }

    @Published private(set) var stack: [PresentedSheet] = []

    var top: PresentedSheet? {
        stack.last
    }

    func present(_ sheet: SheetRoute, onDismiss: (() -> Void)? = nil) {
        let presented = PresentedSheet(route: sheet, onDismiss: onDismiss)
        stack.append(presented)
    }

    func dismissTop() {
        guard let top = stack.popLast() else { return }
        top.onDismiss?()
    }

    func dismiss(at index: Int) {
        guard index >= 0 && index < stack.count else { return }
        let dismissed = stack.remove(at: index)
        dismissed.onDismiss?()
    }

    func dismissAll() {
        while let dismissed = stack.popLast() {
            dismissed.onDismiss?()
        }
    }
}
