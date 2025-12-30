//
//  CalendarEventEditorRepresentable.swift
//  BuyBuy
//
//  Created by MDW on 29-12-2025.
//

import SwiftUI
import EventKit
import EventKitUI

@MainActor
struct CalendarEventEditorRepresentable: UIViewControllerRepresentable {
    let list: ShoppingList
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> EKEventEditViewController {
        let controller = EKEventEditViewController()

        let store = EKEventStore()
        controller.eventStore = store
        controller.editViewDelegate = context.coordinator

        let event = EKEvent(eventStore: store)
        event.title = String(localized: "shopping") + " - " + list.name
        event.notes = createNotes()
        event.calendar = store.defaultCalendarForNewEvents
        controller.event = event

        return controller
    }

    func updateUIViewController(
        _ uiViewController: EKEventEditViewController,
        context: Context
    ) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(dismiss: { dismiss() })
    }
    
    private func createNotes() -> String? {
        let exporter = MessageShoppingListExporter(title: false, exportInfo: false)
        return exporter.exportString(shoppingList: list)
    }

    final class Coordinator: NSObject, EKEventEditViewDelegate {
        let dismiss: () -> Void

        init(dismiss: @escaping () -> Void) {
            self.dismiss = dismiss
        }

        func eventEditViewController(
            _ controller: EKEventEditViewController,
            didCompleteWith action: EKEventEditViewAction
        ) {
            dismiss()
        }
    }
}
