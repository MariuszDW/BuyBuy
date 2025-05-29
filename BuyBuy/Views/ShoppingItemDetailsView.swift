//
//  ShoppingItemDetailsView.swift
//  BuyBuy
//
//  Created by MDW on 20/05/2025.
//

import SwiftUI

enum Field: Hashable {
    case name, note, quantity, unit, pricePerUnit
}

struct ShoppingItemDetailsView: View {
    @StateObject var viewModel: ShoppingItemDetailsViewModel
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focusedField: Field?
    @State private var showImageSourceSheet = false
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        statusSection
                    }
                }
                .listRowBackground(Color.bb.sheet.section.background)
                
                Section {
                    nameField
                    noteField
                }
                .listRowBackground(Color.bb.sheet.section.background)
                
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
                
                Section {
                    ShoppingItemImageGridView(
                        images: viewModel.imageThumbnails,
                        onAddImage: {
                            focusedField = nil
                            showImageSourceSheet = true
                        },
                        onTapImage: { index in
                            focusedField = nil
                            viewModel.handleThumbnailTap(at: index)
                        }
                    )
                }
                .listRowBackground(Color.bb.sheet.section.background)
            }
            .scrollContentBackground(.hidden)
            .background(Color.bb.sheet.background)
            .safeAreaInset(edge: .bottom) {
                if focusedField != nil {
                    HStack {
                        Spacer()
                        Button {
                            focusedField = nil
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
                focusedField = viewModel.isNew ? .name : nil
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Item details")
            .navigationBarTitleDisplayMode(.inline)
            .onChange(of: focusedField) { newValue in
                Task {
                    await viewModel.applyChanges()
                }
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        Task {
                            await viewModel.applyChanges()
                            dismiss()
                        }
                    } label: {
                        Image(systemName: "xmark.circle")
                            .accessibilityLabel("Close")
                    }
                }
            }
            .sheet(isPresented: $showImageSourceSheet) {
                ImageSourcePickerView { image in
                    if let image = image {
                        Task { await viewModel.addImage(image) }
                    }
                }
            }
        }
    }
    
    private var statusSection: some View {
        Group {
            Text("Status")
            Spacer()
            Menu {
                ForEach(ShoppingItemStatus.allCases, id: \.self) { status in
                    Button {
                        focusedField = nil
                        viewModel.status = status
                        Task {
                            await viewModel.applyChanges()
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
                        .foregroundColor(.bb.accent)
                        .padding(.leading, 8)
                }
            }
        }
    }
    
    private var nameField: some View {
        TextField("name", text: viewModel.nameBinding, axis: .vertical)
            .lineLimit(4)
            .multilineTextAlignment(.leading)
            .font(.boldDynamic(style: .title3))
            .focused($focusedField, equals: .name)
            .onSubmit {
                focusedField = nil
            }
    }
    
    private var noteField: some View {
        TextField("note", text: viewModel.noteBinding, axis: .vertical)
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
            Text("Quantity")
                .font(.regularDynamic(style:.caption))
                .foregroundColor(.bb.sheet.section.secondaryText)
                .padding(.leading, 4)
            
            TextField(viewModel.quantityPlaceholder, value: viewModel.quantityBinding, format: .number)
                .keyboardType(.decimalPad)
                .padding(10)
                .background(Color.bb.sheet.background)
                .foregroundColor(.bb.sheet.section.primaryText)
                .cornerRadius(8)
                .focused($focusedField, equals: .quantity)
                .onSubmit {
                    focusedField = nil
                }
        }
        .frame(maxWidth: .infinity)
    }
    
    private var unitField: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Unit")
                .font(.regularDynamic(style:.caption))
                .foregroundColor(.bb.sheet.section.secondaryText)
                .padding(.leading, 4)
            
            HStack(spacing: 8) {
                TextField(viewModel.unitPlaceholder, text: viewModel.unitBinding)
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
                    ForEach(MeasuredUnitCategory.allCases, id: \.self) { category in
                        unitMenuSection(for: category)
                    }
                } label: {
                    Image(systemName: "chevron.up.chevron.down")
                        .foregroundColor(.bb.accent)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    private func unitMenuSection(for category: MeasuredUnitCategory) -> some View {
        return Section(header: Text(category.name)
            .font(.regularDynamic(style:.caption))
            .foregroundColor(.bb.sheet.section.secondaryText)) {
                ForEach(category.units, id: \.self) { unit in
                    Button {
                        focusedField = nil
                        viewModel.unit = unit.symbol
                    } label: {
                        Text(unit.symbol)
                    }
                }
            }
    }
    
    private var priceField: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Price per unit")
                .font(.regularDynamic(style:.caption))
                .foregroundColor(.bb.sheet.section.secondaryText)
                .padding(.leading, 4)
            
            TextField(viewModel.pricePerUnitPlaceholder, value: viewModel.priceBinding, format: .number)
                .keyboardType(.decimalPad)
                .padding(10)
                .background(Color.bb.sheet.background)
                .foregroundColor(.bb.sheet.section.primaryText)
                .cornerRadius(8)
                .focused($focusedField, equals: .pricePerUnit)
                .onSubmit {
                    focusedField = nil
                }
        }
        .frame(maxWidth: .infinity)
    }
    
    private var totalPriceField: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Total price")
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
    let repository = MockShoppingListsRepository()
    let viewModel = ShoppingItemDetailsViewModel(
        item: MockShoppingListsRepository.list1.items.first!,
        repository: repository,
        imageStorage: MockImageStorageService(),
        coordinator: AppCoordinator(dependencies: AppDependencies()))
    
    ShoppingItemDetailsView(viewModel: viewModel)
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    let repository = MockShoppingListsRepository()
    let viewModel = ShoppingItemDetailsViewModel(
        item: MockShoppingListsRepository.list1.items.first!,
        repository: repository,
        imageStorage: MockImageStorageService(),
        coordinator: AppCoordinator(dependencies: AppDependencies()))
    
    ShoppingItemDetailsView(viewModel: viewModel)
        .preferredColorScheme(.dark)
}
