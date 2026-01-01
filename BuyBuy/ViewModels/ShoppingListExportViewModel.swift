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
    
    @Published var includeItemNote: Bool = true
    @Published var includeItemQuantity: Bool = true
    @Published var includeItemPricePerUnit: Bool = true
    @Published var includeItemTotalPrice: Bool = true
    @Published var includeExportInfo: Bool = true

    init(list: ShoppingList, coordinator: any AppCoordinatorProtocol) {
        self.list = list
        self.coordinator = coordinator
    }
    
    func export() {
        guard let data = makeExportData() else { return }
        coordinator.openDocumentExportPicker(with: data, onDismiss: {_ in })
    }
    
    private func makeExportData() -> ExportedData? {
        var exporter = selectedFormat.makeExporter()
        exporter.textEncoding = selectedTextEncoding
        exporter.itemNote = includeItemNote
        exporter.itemQuantity = includeItemQuantity
        exporter.itemPricePerUnit = includeItemPricePerUnit
        exporter.itemTotalPrice = includeItemTotalPrice
        exporter.exportInfo = includeExportInfo

        guard let data = exporter.export(shoppingList: list) else { return nil }

        return ExportedData(data: data, fileName: list.name, fileExtension: selectedFormat.fileExtension)
    }
}
