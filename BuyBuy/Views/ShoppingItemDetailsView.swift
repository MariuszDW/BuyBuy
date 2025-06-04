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
    
    var body: some View {
        NavigationStack {
            content
        }
    }
    
    private var content: some View {
        List {
            statusSection
            nameAndNoteSection
            quantityUnitPriceSection
            imagesSection
        }
        .scrollContentBackground(.hidden)
        .background(Color.bb.sheet.background)
        .safeAreaInset(edge: .bottom) {
            if focusedField != nil {
                hideKeyboardButton
            }
        }
        .task {
            focusedField = viewModel.isNew ? .name : nil
            await viewModel.loadThumbnails()
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Item details")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: focusedField) { newValue in
            Task {
                await viewModel.applyChanges()
            }
        }
        .onDisappear {
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
    }
    
    private var hideKeyboardButton: some View {
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
    
    private var statusSection: some View {
        Section {
            HStack {
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
                            .foregroundColor(.bb.selection)
                            .padding(.leading, 8)
                    }
                }
            }
        }
        .listRowBackground(Color.bb.sheet.section.background)
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
    
    private func unitMenuSection(for category: MeasuredUnitCategory) -> some View {
        return Section(header: Text(category.name)
            .font(.regularDynamic(style:.caption))
            .foregroundColor(.bb.sheet.section.secondaryText)) {
                ForEach(category.units, id: \.self) { unit in
                    Button {
                        focusedField = nil
                        viewModel.unit = unit.symbol
                        Task {
                            await viewModel.applyChanges()
                        }
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
            
            TextField(viewModel.pricePerUnitPlaceholder,
                      value: viewModel.priceBinding,
                      format: .number.precision(.fractionLength(NumberFormatter.priceMinPrecision...NumberFormatter.priceMaxPrecision)))
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
    let dataManager = DataManager(repository: MockDataRepository(lists: [], cards: []),
                                  imageStorage: MockImageStorage())
    let viewModel = ShoppingItemDetailsViewModel(
        item: MockDataRepository.list1.items.first!,
        dataManager: dataManager,
        coordinator: AppCoordinator(dependencies: AppDependencies()))
    
    ShoppingItemDetailsView(viewModel: viewModel)
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    let dataManager = DataManager(repository: MockDataRepository(lists: [], cards: []),
                                  imageStorage: MockImageStorage())
    let viewModel = ShoppingItemDetailsViewModel(
        item: MockDataRepository.list1.items.first!,
        dataManager: dataManager,
        coordinator: AppCoordinator(dependencies: AppDependencies()))
    
    ShoppingItemDetailsView(viewModel: viewModel)
        .preferredColorScheme(.dark)
}
