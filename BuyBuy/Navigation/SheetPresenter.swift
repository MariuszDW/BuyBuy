//
//  SheetPresenter.swift
//  BuyBuy
//
//  Created by MDW on 03/06/2025.
//

import Foundation

enum SheetDisplayStyle {
    case fullScreen
    case sheet
}

final class SheetPresenter: ObservableObject {
    struct PresentedSheet: Identifiable, Equatable {
        let route: SheetRoute
        let displayStyle: SheetDisplayStyle
        let onDismiss: ((SheetRoute) -> Void)? // TODO: Is it necessary?
        let id = UUID()

        static func == (lhs: PresentedSheet, rhs: PresentedSheet) -> Bool {
            lhs.id == rhs.id
        }
    }

    @Published private(set) var stack: [PresentedSheet] = []

    var top: PresentedSheet? {
        stack.last
    }

    func present(
        _ sheet: SheetRoute,
        displayStyle: SheetDisplayStyle = .fullScreen,
        avoidDuplicates: Bool = true,
        onDismiss: ((SheetRoute) -> Void)? = nil
    ) {
        if avoidDuplicates, let top = stack.last, top.route.isSameKind(as: sheet) {
            return // Don't present duplicate sheet if already at the top
        }
        let newSheet = PresentedSheet(route: sheet, displayStyle: displayStyle, onDismiss: onDismiss)
        stack.append(newSheet)
    }

    func dismiss(at index: Int) {
        guard index >= 0 && index < stack.count else { return }
        let dismissed = stack.remove(at: index)
        dismissed.onDismiss?(dismissed.route)
    }

    func dismiss(after index: Int) {
        let nextIndex = index + 1
        guard nextIndex < stack.count else { return }
        dismiss(at: nextIndex)
    }

    func dismissTop() {
        guard let top = stack.popLast() else { return }
        top.onDismiss?(top.route)
    }

    func dismissAll() {
        while let dismissed = stack.popLast() {
            dismissed.onDismiss?(dismissed.route)
        }
    }

    func hasSheet(at index: Int) -> Bool {
        return index >= 0 && index < stack.count
    }

    func hasSheet(after index: Int) -> Bool {
        return (index + 1) < stack.count
    }
}
