//
//  MessageEditorRepresentable.swift
//  BuyBuy
//
//  Created by MDW on 29-12-2025.
//

import SwiftUI
import MessageUI

@MainActor
struct MessageEditorRepresentable: UIViewControllerRepresentable {

    let list: ShoppingList

    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> MFMessageComposeViewController {
        let controller = MFMessageComposeViewController()
        controller.messageComposeDelegate = context.coordinator
        controller.body = createBody()
        return controller
    }

    func updateUIViewController(
        _ uiViewController: MFMessageComposeViewController,
        context: Context
    ) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(dismiss: { dismiss() })
    }

    private func createBody() -> String {
        let exporter = MessageShoppingListExporter(title: true, exportInfo: false)
        return exporter.exportString(shoppingList: list) ?? ""
    }

    final class Coordinator: NSObject, MFMessageComposeViewControllerDelegate {
        let dismiss: () -> Void

        init(dismiss: @escaping () -> Void) {
            self.dismiss = dismiss
        }

        func messageComposeViewController(
            _ controller: MFMessageComposeViewController,
            didFinishWith result: MessageComposeResult
        ) {
            dismiss()
        }
    }
}
