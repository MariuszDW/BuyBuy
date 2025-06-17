//
//  ShoppingListExportViewModel.swift
//  BuyBuy
//
//  Created by MDW on 16/06/2025.
//

import Foundation
import SwiftUI

@MainActor
final class ShoppingListExportViewModel: ObservableObject {
    let list: ShoppingList
    let coordinator: any AppCoordinatorProtocol

    @Published var selectedFormat: ShoppingListExportFormat = .default
    @Published var selectedTextEncoding: TextEncoding = .default

    init(list: ShoppingList, coordinator: any AppCoordinatorProtocol) {
        self.list = list
        self.coordinator = coordinator
    }
    
    func export() {
        guard let data = makeExportData() else { return }
        coordinator.openDocumentExporter(with: data, onDismiss: {_ in })
    }
    
    private func makeExportData() -> ExportedData? {
        var exporter = selectedFormat.makeExporter()
        exporter.textEncoding = selectedTextEncoding

        guard let data = exporter.export(shoppingList: list) else { return nil }

        return ExportedData(data: data, fileName: list.name, fileExtension: selectedFormat.fileExtension)
    }
}
