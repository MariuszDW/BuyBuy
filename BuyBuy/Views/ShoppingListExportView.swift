//
//  ShoppingListExportView.swift
//  BuyBuy
//
//  Created by MDW on 16/06/2025.
//

import SwiftUI

struct ShoppingListExportView: View {
    @StateObject var viewModel: ShoppingListExportViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(viewModel: ShoppingListExportViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                formatSection
            }
            .navigationTitle("list_export")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("export") {
                        viewModel.export()
                    }
                }
            }
        }
    }
    
    private var formatSection: some View {
        Section("file_format") {
            Picker("format", selection: $viewModel.selectedFormat) {
                ForEach(ShoppingListExportFormat.allCases) { format in
                    Text(format.localizedName).tag(format)
                }
            }
        }
    }
}
