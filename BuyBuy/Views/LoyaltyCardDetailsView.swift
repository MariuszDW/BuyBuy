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
    
    @State private var showingImageActionMenu: Bool = false
    @State private var showImageSourceSheet: Bool = false
    @State private var deleteImageConfirmation = false
    
    var body: some View {
        NavigationStack {
            List {
                Section("card_name") {
                    nameSectionContent
                }
                .listRowBackground(Color.bb.sheet.section.background)
                
                Section("card_image") {
                    imageSectionContent()
                }
                .listRowBackground(Color.bb.sheet.section.background)
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
                await viewModel.loadCardImage()
            }
            .listStyle(.insetGrouped)
            .navigationTitle("loyalty_card")
            .navigationBarTitleDisplayMode(.inline)
            .onChange(of: focusedField) { newValue in
                Task {
                    viewModel.finalizeInput()
                }
            }
            .toolbar {
                toolbarContent
            }
            .alert("card_remove_image_title", isPresented: $deleteImageConfirmation) {
                Button("cancel", role: .cancel) {}
                Button("delete", role: .destructive) {
                    Task {
                        await viewModel.deleteCardImage()
                    }
                }
            } message: {
                Text("card_remove_image_message")
            }
            .onDisappear {
                Task {
                    await viewModel.onFinishEditing()
                }
            }
        }
    }
    
    private var imageActionMenu: some View {
        VStack(alignment: .leading, spacing: 24) {
            Button {
                showingImageActionMenu = false
                viewModel.openCardPreview()
            } label: {
                HStack {
                    Text("view_image")
                    Spacer()
                    Image(systemName: "eye")
                }
                .foregroundColor(.bb.selection)
            }
            
            Button {
                showingImageActionMenu = false
                deleteImageConfirmation = true
            } label: {
                HStack {
                    Text("delete")
                    Spacer()
                    Image(systemName: "trash")
                }
                .foregroundColor(.bb.destructive)
            }
        }
        .padding()
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
    
    private var nameSectionContent: some View {
        TextField("card_name", text: $viewModel.loyaltyCard.name, axis: .vertical)
            .lineLimit(8)
            .multilineTextAlignment(.leading)
            .font(.boldDynamic(style: .title3))
            .focused($focusedField, equals: .name)
            .onSubmit {
                focusedField = nil
            }
        
    }
    
    @ViewBuilder
    private func imageSectionContent() -> some View {
        Group {
            if let image = viewModel.cardImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .onTapGesture {
                        focusedField = nil
                        showingImageActionMenu = false
                        viewModel.openCardPreview()
                    }
                    .onLongPressGesture {
                        focusedField = nil
                        showImageSourceSheet = false
                        showingImageActionMenu = true
                    }
                    .popover(isPresented: $showingImageActionMenu) {
                        imageActionMenu
                            .presentationCompactAdaptation(.popover)
                    }
            } else if viewModel.loadingProgress {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .controlSize(.large)
                    .padding(6)
            } else {
                Button {
                    focusedField = nil
                    showingImageActionMenu = false
                    showImageSourceSheet = true
                } label: {
                    Label("add_card_image", systemImage: "plus.circle")
                        .font(.regularDynamic(style: .headline))
                        .foregroundColor(.bb.accent)
                        .padding(6)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                        .cornerRadius(8)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .buttonStyle(.plain)
            }
        }
        .popover(isPresented: $showImageSourceSheet, attachmentAnchor: .rect(.bounds), arrowEdge: .bottom) {
            ImageSourcePickerView { image in
                if let image = image {
                    Task {
                        await viewModel.addCardImage(image)
                    }
                }
            }
            .presentationCompactAdaptation(.popover)
        }
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
