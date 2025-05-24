//
//  ShoppingListsView.swift
//  BuyBuy
//
//  Created by MDW on 14/05/2025.
//

import SwiftUI

struct ShoppingListsView: View {
    @StateObject var viewModel: ShoppingListsViewModel
    
    @State private var localEditMode: EditMode = .inactive
    @State private var listPendingDeletion: ShoppingList?
    @State private var basketAngle: Double = 0
    @State private var animationTimer: Timer? = nil
    
    init(viewModel: ShoppingListsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack {
            if !viewModel.shoppingLists.isEmpty {
                shoppingListsView
                    .environment(\.editMode, $localEditMode)
            } else {
                emptyView(angle: basketAngle)
                    .onAppear {
                        localEditMode = .inactive
                        startBasketAnimation()
                    }
                    .onDisappear {
                        stopBasketAnimation()
                    }
            }
            
            Spacer()
            
            bottomPanel
        }
        .navigationTitle(viewModel.shoppingLists.isEmpty ? "" : "Shopping lists")
        .navigationBarTitleDisplayMode(.large)
        .onChange(of: viewModel.shoppingLists) { newValue in
            if newValue.isEmpty {
                localEditMode = .inactive
            }
        }
        .toolbar {
            toolbarContent
        }
        .alert(item: $listPendingDeletion) { list in
            Alert(
                title: Text("Delete list \"\(list.name)\"?"),
                message: Text("This list contains items. Are you sure you want to delete it?"),
                primaryButton: .destructive(Text("Delete")) {
                    Task {
                        await viewModel.deleteList(id: list.id)
                    }
                },
                secondaryButton: .cancel()
            )
        }
        .onAppear {
            Task {
                await viewModel.loadLists()
            }
        }
    }
    
    // MARK: - Subviews
    
    private var shoppingListsView: some View {
        List {
            ForEach(viewModel.shoppingLists) { list in
                Group {
                    if localEditMode.isEditing {
                        listRow(for: list)
                    } else {
                        NavigationLink(value: AppRoute.shoppingList(list.id)) {
                            listRow(for: list)
                                .contextMenu {
                                    Button {
                                        viewModel.openListSettings(for: list)
                                    } label: {
                                        Label("Edit", systemImage: "square.and.pencil")
                                    }
                                    
                                    Button(role: .destructive) {
                                        Task {
                                            await handleDeleteTapped(for: list)
                                        }
                                    } label: {
                                        Label("Delete", systemImage: "trash.fill")
                                    }
                                }
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                Task {
                                    await handleDeleteTapped(for: list)
                                }
                            } label: {
                                Label("Delete", systemImage: "trash.fill")
                            }
                        }
                        .swipeActions(edge: .leading, allowsFullSwipe: true) {
                            Button {
                                viewModel.openListSettings(for: list)
                            } label: {
                                Label("Edit", systemImage: "square.and.pencil")
                            }
                            .tint(.blue)
                        }
                    }
                }
                .listRowInsets(EdgeInsets(top: 6, leading: 6, bottom: 6, trailing: 16))
            }
            .onDelete { offsets in
                Task {
                    await viewModel.deleteLists(atOffsets: offsets)
                }
            }
            .onMove { indices, newOffset in
                Task {
                    await viewModel.moveLists(fromOffsets: indices, toOffset: newOffset)
                }
            }
        }
        .listStyle(.plain)
    }
    
    private func listRow(for list: ShoppingList) -> some View {
        HStack {
            Image(systemName: list.icon.rawValue)
                .symbolRenderingMode(.palette)
                .foregroundStyle(.white, list.color.color)
                .font(.regularDynamic(style: .largeTitle))
                .scaleEffect(1.2)
                .padding(.leading, 8)
                .padding(.trailing, 2)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(list.name)
                    .foregroundColor(.bb.text.primary)
                    .font(.regularDynamic(style: .title3))
                    .multilineTextAlignment(.leading)
                    .lineLimit(4)
                
                HStack {
                    ShoppingItemStatus.pending.image
                        .font(.regularDynamic(style: .callout))
                        .foregroundColor(ShoppingItemStatus.pending.color)
                    Text("\(list.items(for: .pending).count)")
                        .foregroundColor(ShoppingItemStatus.pending.color)
                        .font(.regularDynamic(style: .callout))
                    
                    ShoppingItemStatus.purchased.image
                        .font(.regularDynamic(style: .callout))
                        .foregroundColor(ShoppingItemStatus.purchased.color)
                        .padding(.leading, 16)
                    Text("\(list.items(for: .purchased).count)")
                        .foregroundColor(ShoppingItemStatus.purchased.color)
                        .font(.regularDynamic(style: .callout))

                    ShoppingItemStatus.inactive.image
                        .font(.regularDynamic(style: .callout))
                        .foregroundColor(ShoppingItemStatus.inactive.color)
                        .padding(.leading, 16)
                    Text("\(list.items(for: .inactive).count)")
                        .foregroundColor(ShoppingItemStatus.inactive.color)
                        .font(.regularDynamic(style: .callout))
                }
            }
            .padding(.leading, 4)
        }
        .padding(.vertical, 2)
    }
    
    private var bottomPanel: some View {
        HStack {
            Button(action: {
                localEditMode = .inactive
                viewModel.openListSettings()
            }) {
                Label("Add list", systemImage: "plus.circle")
            }
            .disabled(localEditMode.isEditing)
            
            Spacer()
        }
        .padding()
    }
    
    private var toolbarContent: some ToolbarContent {
        Group {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    viewModel.openAbout()
                } label: {
                    Image(systemName: "questionmark.circle")
                }
                .accessibilityLabel("About")
                .disabled(localEditMode.isEditing)
            }
            
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button {
                    withAnimation {
                        localEditMode = (localEditMode == .active) ? .inactive : .active
                    }
                } label: {
                    Image(systemName: localEditMode == .active ? "checkmark" : "pencil.circle")
                }
                .disabled(viewModel.shoppingLists.isEmpty)
                .accessibilityLabel(localEditMode == .active ? "Done Editing" : "Edit")
                
                Button {
                    localEditMode = .inactive
                    viewModel.openSettings()
                } label: {
                    Image(systemName: "gearshape")
                }
                .accessibilityLabel("Settings")
                .disabled(localEditMode.isEditing)
            }
        }
    }
    
    @ViewBuilder
    private func emptyView(angle: Double) -> some View {
        GeometryReader { geometry in
            let baseSize = min(geometry.size.width, geometry.size.height)
            let listImageSize = baseSize * 0.8
            let basketImageSize = baseSize * 0.4
            
            VStack(spacing: 50) {
                ZStack {
                    Image(systemName: "list.bullet.clipboard.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: listImageSize, height: listImageSize)
                        .foregroundColor(.bb.grey85)

                    Image(systemName: "basket.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: basketImageSize, height: basketImageSize)
                        .foregroundColor(.bb.grey85)
                        .offset(x: -basketImageSize * 0.5, y: 0)
                        .rotationEffect(Angle(degrees: angle), anchor: .topLeading)
                        .offset(x: basketImageSize * 0.5, y: 0)
                        .offset(x: listImageSize * 0.2, y: listImageSize * 0.38)
                        .shadow(color: .black.opacity(0.5), radius: 8)
                }
                
                Text("No shopping lists available.")
                    .font(.boldDynamic(style: .title2))
                    .foregroundColor(.bb.grey75)
                    .multilineTextAlignment(.center)

                Text("Tap the \"Add list\" button to create a new list.")
                    .font(.boldDynamic(style: .headline))
                    .foregroundColor(.bb.grey75)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .position(x: geometry.size.width * 0.5, y: geometry.size.height * 0.5)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 40)
    }

    // MARK: - Private
    
    private func startBasketAnimation() {
        animationTimer?.invalidate()
        animationTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { _ in
            let now = Date().timeIntervalSinceReferenceDate
            let newAngle = sin(now * 3) * 16
            DispatchQueue.main.async {
                basketAngle = newAngle
            }
        }
    }

    private func stopBasketAnimation() {
        animationTimer?.invalidate()
        animationTimer = nil
    }
    
    private func handleDeleteTapped(for list: ShoppingList) async {
        Task {
            if list.items.isEmpty {
                await viewModel.deleteList(id: list.id)
            } else {
                listPendingDeletion = list
            }
        }
    }
}

// MARK: - Preview

#Preview("Light/items") {
    let mockViewModel = ShoppingListsViewModel(
        coordinator: AppCoordinator(dependencies: AppDependencies()),
        repository: MockShoppingListsRepository()
    )
    
    NavigationStack {
        ShoppingListsView(viewModel: mockViewModel)
    }
    .preferredColorScheme(.light)
}

#Preview("Dark/items") {
    let mockViewModel = ShoppingListsViewModel(
        coordinator: AppCoordinator(dependencies: AppDependencies()),
        repository: MockShoppingListsRepository()
    )
    
    NavigationStack {
        ShoppingListsView(viewModel: mockViewModel)
    }
    .preferredColorScheme(.dark)
}

#Preview("Light/empty") {
    let mockViewModel = ShoppingListsViewModel(
        coordinator: AppCoordinator(dependencies: AppDependencies()),
        repository: MockShoppingListsRepository(lists: [])
    )
    
    NavigationStack {
        ShoppingListsView(viewModel: mockViewModel)
    }
    .preferredColorScheme(.light)
}

#Preview("Dark/empty") {
    let mockViewModel = ShoppingListsViewModel(
        coordinator: AppCoordinator(dependencies: AppDependencies()),
        repository: MockShoppingListsRepository(lists: [])
    )
    
    NavigationStack {
        ShoppingListsView(viewModel: mockViewModel)
    }
    .preferredColorScheme(.dark)
}
