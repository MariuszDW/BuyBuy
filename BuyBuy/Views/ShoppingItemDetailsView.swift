//
//  ShoppingItemDetailsView.swift
//  BuyBuy
//
//  Created by MDW on 20/05/2025.
//

import SwiftUI

enum ShoppingItemDetailsField: Hashable {
    case name, note, quantity, unit, pricePerUnit
}

struct ShoppingItemDetailsView: View {
    @StateObject var viewModel: ShoppingItemDetailsViewModel
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focusedField: ShoppingItemDetailsField?
    
    @State private var priceFieldString: String = ""
    @State private var quantityFieldString: String = ""
    
    init(viewModel: ShoppingItemDetailsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationStack {
            content
        }
    }
    
    private var content: some View {
        List {
            Section {
                statusView
                
                if let currentList = viewModel.itemList {
                    let lists = viewModel.shoppingLists
                    if lists.count > 1 {
                        listView(currentList, lists: lists)
                    }
                }
            }
            .listRowBackground(Color.bb.sheet.section.background)
            
            nameAndNoteSection
            quantityUnitPriceSection
            imagesSection
        }
        .scrollContentBackground(.hidden)
        .background(Color.bb.sheet.background)
        .safeAreaInset(edge: .bottom) {
            if focusedField != nil {
                KeyboardDismissButton {
                    focusedField = nil
                }
            }
        }
        .task {
            focusedField = viewModel.isNew ? .name : nil
            await viewModel.loadThumbnails()
            await viewModel.loadShoppingLists()
            priceFieldString = viewModel.priceString
            quantityFieldString = viewModel.quantityString
        }
        .listStyle(.insetGrouped)
        .navigationTitle("shopping_item")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: focusedField) { newValue in
            Task {
                viewModel.finalizeInput()
            }
        }
        .toolbar {
            toolbarContent
        }
        .onAppear {
            AppLogger.general.info("ShoppingItemDetailsView onAppear")
            viewModel.startObserving()
        }
        .onDisappear {
            AppLogger.general.info("ShoppingItemDetailsView onDisappear")
            viewModel.stopObserving()
            Task { await viewModel.didFinishEditing() }
        }
    }
    
    private var toolbarContent: some ToolbarContent {
        Group {
            if viewModel.isNew {
                ToolbarItem(placement: .cancellationAction) {
                    Button("cancel") {
                        Task {
                            viewModel.changesConfirmed = false
                            dismiss()
                        }
                    }
                }
            }
            
            ToolbarItem(placement: .confirmationAction) {
                Button("ok") {
                    Task {
                        viewModel.changesConfirmed = true
                        dismiss()
                    }
                }
                .disabled(!viewModel.canConfirm)
            }
        }
    }
    
    private var statusView: some View {
        HStack {
            Text("status")
            Spacer()
            Menu {
                ForEach(ShoppingItemStatus.allCases, id: \.self) { status in
                    Button {
                        focusedField = nil
                        viewModel.shoppingItem.status = status
                        Task {
                            viewModel.finalizeInput()
                        }
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
                        .foregroundColor(.bb.selection)
                        .padding(.leading, 4)
                }
            }
        }
    }
    
    private func listView(_ currentList: ShoppingList, lists: [ShoppingList]) -> some View {
        return HStack {
            Text("list")
            Spacer()
            Menu {
                ForEach(lists, id: \.id) { list in
                    Button {
                        focusedField = nil
                        Task {
                            await viewModel.moveToShoppingList(with: list.id)
                            viewModel.finalizeInput()
                        }
                    } label: {
                        HStack {
                            list.icon.image
                                .symbolRenderingMode(.palette)
                                .foregroundStyle(.white, list.color.color)
                            
                            Text(list.name)
                                .lineLimit(1)
                                .truncationMode(.tail)
                        }
                    }
                }
            } label: {
                HStack(spacing: 8) {
                    currentList.icon.image
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.white, currentList.color.color)
                    
                    Text(currentList.name)
                        .foregroundColor(currentList.color.color)
                        .lineLimit(1)
                        .truncationMode(.tail)
                    
                    Image(systemName: "chevron.up.chevron.down")
                        .foregroundColor(.bb.selection)
                        .padding(.leading, 4)
                }
            }
        }
    }
    
    private var quantityUnitPriceSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 12) {
                    quantityField
                    unitField
                }
                
                HStack(spacing: 12) {
                    priceField
                    totalPriceField
                }
            }
        }
        .listRowBackground(Color.bb.sheet.section.background)
    }
    
    private var nameAndNoteSection: some View {
        Section {
            nameField
            noteField
        }
        .listRowBackground(Color.bb.sheet.section.background)
    }
    
    private var nameField: some View {
        TextField("name", text: $viewModel.shoppingItem.name, axis: .vertical)
            .lineLimit(4)
            .multilineTextAlignment(.leading)
            .font(.boldDynamic(style: .title3))
            .focused($focusedField, equals: .name)
            .onSubmit {
                focusedField = nil
            }
    }
    
    private var noteField: some View {
        TextField("note", text: $viewModel.shoppingItem.note, axis: .vertical)
            .lineLimit(8)
            .multilineTextAlignment(.leading)
            .font(.regularDynamic(style: .body))
            .focused($focusedField, equals: .note)
            .onSubmit {
                focusedField = nil
            }
    }
    
    private var quantityField: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("quantity")
                .font(.regularDynamic(style:.caption))
                .foregroundColor(.bb.sheet.section.secondaryText)
                .padding(.leading, 4)
            
            TextField(viewModel.quantityPlaceholder, text: $quantityFieldString)
                .keyboardType(.decimalPad)
                .padding(10)
                .background(Color.bb.sheet.background)
                .foregroundColor(.bb.sheet.section.primaryText)
                .cornerRadius(8)
                .focused($focusedField, equals: .quantity)
                .onChange(of: quantityFieldString) { newValue in
                    viewModel.quantityString = newValue
                }
                .onChange(of: viewModel.quantityString) { newValue in
                    if focusedField != .quantity {
                        quantityFieldString = newValue
                    }
                }
                .onChange(of: focusedField) { newValue in
                    if newValue != .quantity {
                        quantityFieldString = viewModel.quantityString
                    }
                }
                .onSubmit {
                    focusedField = nil
                }
        }
        .frame(maxWidth: .infinity)
    }
    
    private var unitField: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("unit")
                .font(.regularDynamic(style:.caption))
                .foregroundColor(.bb.sheet.section.secondaryText)
                .padding(.leading, 4)
            
            HStack(spacing: 8) {
                TextField(viewModel.unitPlaceholder, text: $viewModel.unit)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .padding(10)
                    .background(Color.bb.sheet.background)
                    .foregroundColor(.bb.sheet.section.primaryText)
                    .cornerRadius(8)
                    .focused($focusedField, equals: .unit)
                    .onSubmit {
                        focusedField = nil
                    }
                
                Menu {
                    ForEach(viewModel.unitList, id: \.name) { section in
                        unitMenuSection(name: section.name, units: section.units)
                    }
                } label: {
                    Image(systemName: "chevron.up.chevron.down")
                        .foregroundColor(.bb.selection)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    private var imagesSection: some View {
        Section {
            ShoppingItemImageGridView(
                images: viewModel.thumbnails,
                onUserInteraction: {
                    focusedField = nil
                },
                onAddImage: { image in
                    Task { await viewModel.addImage(image) }
                },
                onTapImage: { imageIndex in
                    viewModel.openImagePreview(at: imageIndex)
                },
                onDeleteImage: { imageIndex in
                    Task { await viewModel.deleteImage(at: imageIndex) }
                }
            )
        }
        .listRowBackground(Color.bb.sheet.section.background)
    }
    
    private func unitMenuSection(name sectionName: String, units: [MeasuredUnit]) -> some View {
        return Section(header: Text(sectionName)
            .font(.regularDynamic(style:.caption))
            .foregroundColor(.bb.sheet.section.secondaryText)) {
                ForEach(units, id: \.self) { unit in
                    Button {
                        focusedField = nil
                        viewModel.unit = unit.symbol
                        Task {
                            viewModel.finalizeInput()
                        }
                    } label: {
                        Text(unit.symbol + " - " + unit.name)
                    }
                }
            }
    }
    
    private var priceField: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("price_per_unit")
                .font(.regularDynamic(style:.caption))
                .foregroundColor(.bb.sheet.section.secondaryText)
                .padding(.leading, 4)
            
            TextField(viewModel.pricePerUnitPlaceholder, text: $priceFieldString)
                .keyboardType(.decimalPad)
                .padding(10)
                .background(Color.bb.sheet.background)
                .foregroundColor(.bb.sheet.section.primaryText)
                .cornerRadius(8)
                .focused($focusedField, equals: .pricePerUnit)
                .onChange(of: priceFieldString) { newValue in
                    viewModel.priceString = newValue
                }
                .onChange(of: viewModel.priceString) { newValue in
                    if focusedField != .pricePerUnit {
                        priceFieldString = newValue
                    }
                }
                .onChange(of: focusedField) { newValue in
                    if newValue != .pricePerUnit {
                        priceFieldString = viewModel.priceString
                    } else {
                        if let price = viewModel.shoppingItem.price {
                            let hasFraction = price.truncatingRemainder(dividingBy: 1) != 0
                            priceFieldString = hasFraction ? viewModel.priceString : String(format: "%.0f", price)
                        } else {
                            priceFieldString = ""
                        }
                    }
                }
                .onSubmit {
                    focusedField = nil
                }
        }
        .frame(maxWidth: .infinity)
    }
    
    private var totalPriceField: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("total_price")
                .font(.regularDynamic(style:.caption))
                .foregroundColor(.bb.sheet.section.secondaryText)
                .padding(.leading, 4)
            
            Text(viewModel.totalPriceString)
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

// MARK: - Preview

#Preview("Light") {
    let dataManager = DataManager(useCloud: false,
                                  repository: MockDataRepository(cards: []))
    let preferences = MockAppPreferences()
    let coordinator = AppCoordinator(preferences: preferences)
    let viewModel = ShoppingItemDetailsViewModel(
        item: MockDataRepository.list1.items.first!,
        dataManager: dataManager,
        preferences: preferences,
        coordinator: coordinator)
    
    ShoppingItemDetailsView(viewModel: viewModel)
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    let dataManager = DataManager(useCloud: false,
                                  repository: MockDataRepository(cards: []))
    let preferences = MockAppPreferences()
    let coordinator = AppCoordinator(preferences: preferences)
    let viewModel = ShoppingItemDetailsViewModel(
        item: MockDataRepository.list1.items.first!,
        dataManager: dataManager,
        preferences: preferences,
        coordinator: coordinator)
    
    ShoppingItemDetailsView(viewModel: viewModel)
        .preferredColorScheme(.dark)
}
