//
//  ShoppingItemDetailsView.swift
//  BuyBuy
//
//  Created by MDW on 20/05/2025.
//

import SwiftUI

struct ShoppingItemDetailsView: View {
    @StateObject var viewModel: ShoppingItemDetailsViewModel
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isNameFocused: Bool
    @FocusState private var isNoteFocused: Bool
    @FocusState private var isQuantityFocused: Bool
    @FocusState private var isUnitFocused: Bool
    @FocusState private var isPricePerUnitFocused: Bool
    
    var body: some View {
        NavigationStack {
            List {
                statusSection
                nameAndNoteSection
                
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        quantityAndUnit
                        priceAndTotalPrice
                    }
                }
                .listRowBackground(Color.bb.sheet.section.background)
            }
            .scrollContentBackground(.hidden)
            .background(Color.sheetBackground)
            .safeAreaInset(edge: .bottom) {
                if isNameFocused || isNoteFocused || isQuantityFocused || isUnitFocused || isPricePerUnitFocused {
                    HStack {
                        Spacer()
                        Button {
                            clearTextFieldFocus()
                        } label: {
                            Image(systemName: "keyboard.chevron.compact.down")
                                .font(.regularDynamic(style: .title2))
                                .foregroundColor(.bb.accent)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(Color.bb.background.opacity(0.5))
                                )
                        }
                    }
                }
            }
            .task {
                isNameFocused = viewModel.isNew
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Item details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("OK") {
                        Task {
                            await viewModel.applyChanges()
                            dismiss()
                        }
                    }
                    .disabled(viewModel.shoppingItem.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
    
    private var statusSection: some View {
        Section {
            HStack {
                Text("Status")
                Spacer()
                Menu {
                    ForEach(ShoppingItemStatus.allCases, id: \.self) { status in
                        Button {
                            viewModel.shoppingItem.status = status
                        } label: {
                            Label(status.localizedName, systemImage: status.imageSystemName)
                                .foregroundColor(status.color)
                        }
                    }
                } label: {
                    let status = viewModel.shoppingItem.status
                    HStack(spacing: 8) {
                        status.image
                            .foregroundColor(status.color)
                        Text(status.localizedName)
                            .foregroundColor(status.color)
                        Image(systemName: "chevron.up.chevron.down")
                            .foregroundColor(.bb.accent)
                            .padding(.leading, 8)
                    }
                }
            }
        }
        .listRowBackground(Color.bb.sheet.section.background)
    }
    
    private var nameAndNoteSection: some View {
        Section {
            TextField("name", text: $viewModel.shoppingItem.name, axis: .vertical)
                .lineLimit(4)
                .multilineTextAlignment(.leading)
                .font(.boldDynamic(style: .title3))
                .focused($isNameFocused)
                .onSubmit {
                    isNameFocused = false
                }
            
            TextField("note", text: $viewModel.shoppingItem.note, axis: .vertical)
                .lineLimit(8)
                .multilineTextAlignment(.leading)
                .font(.regularDynamic(style: .body))
                .focused($isNoteFocused)
                .onSubmit {
                    isNoteFocused = false
                }
        }
        .listRowBackground(Color.bb.sheet.section.background)
    }
    
    private var quantityAndUnit: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Quantity")
                    .font(.regularDynamic(style:.caption))
                    .foregroundColor(.bb.sheet.section.secondaryText)
                    .padding(.leading, 4)
                
                TextField(quantityPlaceholder, value: $viewModel.shoppingItem.quantity, format: .number)
                    .keyboardType(.decimalPad)
                    .padding(10)
                    .background(Color.bb.sheet.background)
                    .foregroundColor(.bb.sheet.section.primaryText)
                    .cornerRadius(8)
                    .focused($isQuantityFocused)
                    .onSubmit {
                        isQuantityFocused = false
                    }
            }
            .frame(maxWidth: .infinity)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Unit")
                    .font(.regularDynamic(style:.caption))
                    .foregroundColor(.bb.sheet.section.secondaryText)
                    .padding(.leading, 4)
                
                HStack(spacing: 8) {
                    TextField(unitPlaceholder, text: $viewModel.shoppingItem.unitText)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .padding(10)
                        .background(Color.bb.sheet.background)
                        .foregroundColor(.bb.sheet.section.primaryText)
                        .cornerRadius(8)
                        .focused($isUnitFocused)
                        .onSubmit {
                            isUnitFocused = false
                        }
                    
                    Menu {
                        ForEach(MeasuredUnitCategory.allCases, id: \.self) { category in
                            Section(header: Text(category.name)
                                .font(.regularDynamic(style:.caption))
                                .foregroundColor(.bb.sheet.section.secondaryText)) {
                                    ForEach(category.units, id: \.self) { unit in
                                        Button {
                                            viewModel.shoppingItem.unitText = unit.symbol
                                        } label: {
                                            Text(unit.symbol)
                                        }
                                    }
                                }
                        }
                    } label: {
                        Image(systemName: "chevron.up.chevron.down")
                            .foregroundColor(.bb.accent)
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    private var priceAndTotalPrice: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Price per unit")
                    .font(.regularDynamic(style:.caption))
                    .foregroundColor(.bb.sheet.section.secondaryText)
                    .padding(.leading, 4)
                
                TextField(pricePerUnitPlaceholder, value: $viewModel.shoppingItem.price, format: .number)
                    .keyboardType(.decimalPad)
                    .padding(10)
                    .background(Color.bb.sheet.background)
                    .foregroundColor(.bb.sheet.section.primaryText)
                    .cornerRadius(8)
                    .focused($isPricePerUnitFocused)
                    .onSubmit {
                        isPricePerUnitFocused = false
                    }
            }
            .frame(maxWidth: .infinity)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Total price")
                    .font(.regularDynamic(style:.caption))
                    .foregroundColor(.bb.sheet.section.secondaryText)
                    .padding(.leading, 4)
                
                Text(viewModel.shoppingItem.totalPriceString ?? "N/A")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(10)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.bb.sheet.background, lineWidth: 1)
                    )
                    .foregroundColor(.bb.sheet.section.primaryText)
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    private var quantityPlaceholder: String {
        let formatter = NumberFormatter.localizedDecimal(minFractionDigits: 1)
        let valueString = formatter.string(from: 1.5) ?? "1.5"
        return "e.g. \(valueString)"
    }
    
    private var unitPlaceholder: String {
        let unitExampleString = Locale.current.measurementSystem == "Metric" ? MeasuredUnit.kilogram.symbol : MeasuredUnit.pound.symbol
        return "e.g. \(unitExampleString)"
    }
    
    private var pricePerUnitPlaceholder: String{
        let formatter = NumberFormatter.localizedDecimal(minFractionDigits: 1)
        let valueString = formatter.string(from: 10.99) ?? "10.99"
        return "e.g. \(valueString)"
    }
    
    private func clearTextFieldFocus() {
        isNameFocused = false
        isNoteFocused = false
        isQuantityFocused = false
        isUnitFocused = false
        isPricePerUnitFocused = false
    }
}

// MARK: - Preview

#Preview("Light") {
    let repository = MockShoppingListsRepository()
    let viewModel = ShoppingItemDetailsViewModel(
        item: MockShoppingListsRepository.list1.items.first!,
        repository: repository,
        coordinator: AppCoordinator(dependencies: AppDependencies()),
        onSave: {})
    
    ShoppingItemDetailsView(viewModel: viewModel)
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    let repository = MockShoppingListsRepository()
    let viewModel = ShoppingItemDetailsViewModel(
        item: MockShoppingListsRepository.list1.items.first!,
        repository: repository,
        coordinator: AppCoordinator(dependencies: AppDependencies()),
        onSave: {})
    
    ShoppingItemDetailsView(viewModel: viewModel)
        .preferredColorScheme(.dark)
}
