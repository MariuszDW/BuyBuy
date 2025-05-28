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
    
    // TODO: Replace the focus states with a different solution.
    @FocusState private var isNameFocused: Bool
    @FocusState private var isNoteFocused: Bool
    @FocusState private var isQuantityFocused: Bool
    @FocusState private var isUnitFocused: Bool
    @FocusState private var isPricePerUnitFocused: Bool
    
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
                            showImageSourceSheet = true
                        },
                        onTapImage: { index in
                            viewModel.handleThumbnailTap(at: index)
                        }
                    )
                }
                .listRowBackground(Color.bb.sheet.section.background)
            }
            .scrollContentBackground(.hidden)
            .background(Color.bb.sheet.background)
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
                    .disabled(viewModel.isOkButtonDisabled)
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
                        viewModel.status = status
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
        // TODO: Workaround for Apple's bug (https://developer.apple.com/forums/thread/738726)
        // .onLongPressGesture(minimumDuration: 0.0) {
        //     isNameFocused = true
        // }
            .focused($isNameFocused)
            .onSubmit {
                isNameFocused = false
            }
    }
    
    private var noteField: some View {
        TextField("note", text: viewModel.noteBinding, axis: .vertical)
            .lineLimit(8)
            .multilineTextAlignment(.leading)
            .font(.regularDynamic(style: .body))
            .focused($isNoteFocused)
            .onSubmit {
                isNoteFocused = false
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
                .focused($isQuantityFocused)
                .onSubmit {
                    isQuantityFocused = false
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
                    .focused($isUnitFocused)
                    .onSubmit {
                        isUnitFocused = false
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
                .focused($isPricePerUnitFocused)
                .onSubmit {
                    isPricePerUnitFocused = false
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
        imageStorage: MockImageStorageService(),
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
        imageStorage: MockImageStorageService(),
        coordinator: AppCoordinator(dependencies: AppDependencies()),
        onSave: {})
    
    ShoppingItemDetailsView(viewModel: viewModel)
        .preferredColorScheme(.dark)
}
