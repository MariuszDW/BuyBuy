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
                itemDetailsSection
                otherOptionsSection
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
    
    private var formatSectionFooter: some View {
        Group {
            if viewModel.selectedTextEncoding.mayLoseInformation {
                Text("export_character_loss_warning")
                    .font(.regularDynamic(style: .caption))
                    .foregroundColor(.bb.text.tertiary)
            }
        }
    }
    
    private var formatSection: some View {
        Section(header: Text("file_format"), footer: formatSectionFooter) {
            Picker("format", selection: $viewModel.selectedFormat) {
                ForEach(ShoppingListExportFormat.allCases) { format in
                    Text(format.localizedName)
                        .font(.regularDynamic(style: .body))
                        .tag(format)
                }
            }
            Picker("text_encoding", selection: $viewModel.selectedTextEncoding) {
                ForEach(TextEncoding.allCases) { encoding in
                    Text(encoding.rawValue)
                        .tag(encoding)
                        .font(.regularDynamic(style: .body))
                }
            }
        }
    }
    
    private var itemDetailsSection: some View {
        Section("item_details") {
            Toggle(LocalizedStringKey("note"), isOn: $viewModel.includeItemNote)
            Toggle(LocalizedStringKey("quantity"), isOn: $viewModel.includeItemQuantity)
            Toggle(LocalizedStringKey("price_per_unit"), isOn: $viewModel.includeItemPricePerUnit)
            Toggle(LocalizedStringKey("total_price"), isOn: $viewModel.includeItemTotalPrice)
        }
    }
    
    private var otherOptionsSection: some View {
        Section(footer: Text("export_info_footer")) {
            Toggle(LocalizedStringKey("export_info"), isOn: $viewModel.includeExportInfo)
        }
    }
}

// MARK: - Preview

#Preview("Light") {
    let preferences = MockAppPreferences()
    let coordinator = AppCoordinator(preferences: preferences)
    let viewModel = ShoppingListExportViewModel(list: MockDataRepository.list1,
                                                coordinator: coordinator)
    
    NavigationStack {
        ShoppingListExportView(viewModel: viewModel)
    }
    .preferredColorScheme(.light)
}

#Preview("Dark") {
    let preferences = MockAppPreferences()
    let coordinator = AppCoordinator(preferences: preferences)
    let viewModel = ShoppingListExportViewModel(list: MockDataRepository.list1,
                                                coordinator: coordinator)
    
    NavigationStack {
        ShoppingListExportView(viewModel: viewModel)
    }
    .preferredColorScheme(.dark)
}

