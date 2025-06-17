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
                listNameSection
                formatSection
                optionsSection
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
    
    private var listNameSection: some View {
        Section("shopping_list") {
            HStack {
                Image(systemName: viewModel.list.icon.rawValue)
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.white, viewModel.list.color.color)
                    .font(.regularDynamic(style: .title))
                
                Text(viewModel.list.name)
                    .foregroundColor(.bb.text.primary)
                    .font(.regularDynamic(style: .title3))
                    .multilineTextAlignment(.leading)
                    .lineLimit(4)
            }
        }
    }
    
    private var formatSection: some View {
        Section("file_format") {
            Picker("format", selection: $viewModel.selectedFormat) {
                ForEach(ShoppingListExportFormat.allCases) { format in
                    Text(format.localizedName)
                        .font(.regularDynamic(style: .body))
                        .tag(format)
                }
            }
            Picker("text_encoding", selection: $viewModel.selectedTextEncoding) {
                ForEach(TextEncoding.allCases) { encoding in
                    Text(encoding.rawValue).tag(encoding)
                        .font(.regularDynamic(style: .body))
                }
            }
            if viewModel.selectedTextEncoding.mayLoseInformation {
                Text("export_character_loss_warning")
                    .font(.regularDynamic(style: .caption))
                    .foregroundColor(.bb.text.tertiary)
            }
        }
    }
    
    private var optionsSection: some View {
        Section("options") {
            
        }
    }
}

// MARK: - Preview

#Preview("Light") {
    let coordinator = AppCoordinator(dependencies: AppDependencies())
    let viewModel = ShoppingListExportViewModel(list: MockDataRepository.list1,
                                                coordinator: coordinator)
    
    NavigationStack {
        ShoppingListExportView(viewModel: viewModel)
    }
    .preferredColorScheme(.light)
}

#Preview("Dark") {
    let coordinator = AppCoordinator(dependencies: AppDependencies())
    let viewModel = ShoppingListExportViewModel(list: MockDataRepository.list1,
                                                coordinator: coordinator)
    
    NavigationStack {
        ShoppingListExportView(viewModel: viewModel)
    }
    .preferredColorScheme(.dark)
}

