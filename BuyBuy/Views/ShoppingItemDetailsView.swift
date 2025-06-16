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
                keyboardDismissButton
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
        .onDisappear {
            Task {
                await viewModel.didFinishEditing()
            }
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
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("ok") {
                        Task {
                            viewModel.changesConfirmed = true
                            dismiss()
                        }
                    }
                    .disabled(!viewModel.canConfirm)
                }
            } else {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        Task {
                            viewModel.changesConfirmed = true
                            dismiss()
                        }
                    } label: {
                        Image(systemName: "xmark.circle")
                            // .accessibilityLabel("Close")
                    }
                    .disabled(!viewModel.canConfirm)
                }
            }
        }
    }
    
    private var keyboardDismissButton: some View {
        HStack {
            Spacer()
            Button {
                focusedField = nil
            } label: {
                Image(systemName: "keyboard.chevron.compact.down")
                    .font(.regularDynamic(style: .title2))
                    .foregroundColor(.bb.selection)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.bb.background.opacity(0.5))
                    )
            }
        }
    }
    
    private var statusView: some View {
        HStack {
            Text("item_status")
            Spacer()
            Menu {
                ForEach(ShoppingItemStatus.allCases, id: \.self) { status in
                    Button {
                        focusedField = nil
                        viewModel.status = status
                        Task {
                            viewModel.finalizeInput()
                        }
                    } label: {
                        Label(status.localizedName, systemImage: status.imageSystemName)
                            .foregroundColor(status.color)
                    }
                }
            } label: {
                let status = viewModel.status
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
            Text("item_list")
            Spacer()
            Menu {
                ForEach(lists, id: \.id) { list in
                    Button {
                        focusedField = nil
                        viewModel.listID = list.id
                        Task {
                            viewModel.finalizeInput()
                        }
                    } label: {
                        HStack {
                            list.icon.image
                            Text(list.name)
                                .lineLimit(1)
                                .truncationMode(.tail)
//                            if list.id == currentList.id {
//                                Spacer()
//                                Image(systemName: "checkmark")
//                                    .foregroundColor(.accentColor)
//                            }
                        }
                    }
                }
            } label: {
                HStack(spacing: 8) {
                    currentList.icon.image
                        .foregroundColor(currentList.color.color)
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
        TextField("item_name", text: $viewModel.name, axis: .vertical)
            .lineLimit(4)
            .multilineTextAlignment(.leading)
            .font(.boldDynamic(style: .title3))
            .focused($focusedField, equals: .name)
            .onSubmit {
                focusedField = nil
            }
    }
    
    private var noteField: some View {
        TextField("item_note", text: $viewModel.note, axis: .vertical)
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
            Text("item_quantity")
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
            Text("item_unit")
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
                        Text(unit.symbol)
                    }
                }
            }
    }
    
    private var priceField: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("item_price_per_unit")
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
                .onChange(of: focusedField) { newValue in
                    if newValue != .pricePerUnit {
                        priceFieldString = viewModel.priceString
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
            Text("item_total_price")
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
    let dataManager = DataManager(repository: MockDataRepository(cards: []),
                                  imageStorage: MockImageStorage())
    let viewModel = ShoppingItemDetailsViewModel(
        item: MockDataRepository.list1.items.first!,
        dataManager: dataManager,
        coordinator: AppCoordinator(dependencies: AppDependencies()))
    
    ShoppingItemDetailsView(viewModel: viewModel)
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    let dataManager = DataManager(repository: MockDataRepository(cards: []),
                                  imageStorage: MockImageStorage())
    let viewModel = ShoppingItemDetailsViewModel(
        item: MockDataRepository.list1.items.first!,
        dataManager: dataManager,
        coordinator: AppCoordinator(dependencies: AppDependencies()))
    
    ShoppingItemDetailsView(viewModel: viewModel)
        .preferredColorScheme(.dark)
}
