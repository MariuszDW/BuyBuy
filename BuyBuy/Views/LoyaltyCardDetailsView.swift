//
//  LoyaltyCardDetailsView.swift
//  BuyBuy
//
//  Created by MDW on 04/06/2025.
//

import SwiftUI

enum LoyaltyCardDetailsField: Hashable {
    case name
}

struct LoyaltyCardDetailsView: View {
    @StateObject var viewModel: LoyaltyCardDetailsViewModel
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focusedField: LoyaltyCardDetailsField?
    
    var body: some View {
        NavigationStack {
            List {
                nameSection
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
                await viewModel.loadCardThumbnail()
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Loyalty card details")
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
    
    private var nameSection: some View {
        Section {
            nameField
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
    
    private var imagesSection: some View {
        Section {
            Text("TODO: image")
        }
        .listRowBackground(Color.bb.sheet.section.background)
    }
}

// MARK: - Preview

#Preview("Light") {
    let dataManager = DataManager(repository: MockDataRepository(lists: [], cards: []),
                                  imageStorage: MockImageStorage())
    let viewModel = LoyaltyCardDetailsViewModel(
        card: MockDataRepository.card1,
        dataManager: dataManager,
        coordinator: AppCoordinator(dependencies: AppDependencies()))
    
    LoyaltyCardDetailsView(viewModel: viewModel)
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    let dataManager = DataManager(repository: MockDataRepository(lists: [], cards: []),
                                  imageStorage: MockImageStorage())
    let viewModel = LoyaltyCardDetailsViewModel(
        card: MockDataRepository.card1,
        dataManager: dataManager,
        coordinator: AppCoordinator(dependencies: AppDependencies()))
    
    LoyaltyCardDetailsView(viewModel: viewModel)
        .preferredColorScheme(.dark)
}
