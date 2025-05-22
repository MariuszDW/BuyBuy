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
    
    init(viewModel: ShoppingListsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack {
            lists
                .environment(\.editMode, $localEditMode)
            bottomPanel
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
    
    private var lists: some View {
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
                                        viewModel.openListSettings(list)
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
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
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
                                viewModel.openListSettings(list)
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
                .font(.title)

            Text(list.name)
                .foregroundColor(.text)
                .padding(.vertical, 8)
            
            Spacer()
            
            Text("\(list.items(for: .purchased).count) / \(list.items(for: .pending).count + list.items(for: .purchased).count)")
                .foregroundColor(.secondary)
                .font(.subheadline)
        }
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
    
    // MARK: - Private
    
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

#Preview("Light Mode") {
    let mockViewModel = ShoppingListsViewModel(
        coordinator: AppCoordinator(dependencies: AppDependencies()),
        repository: MockShoppingListsRepository()
    )
    
    NavigationStack {
        ShoppingListsView(viewModel: mockViewModel)
    }
    .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    let mockViewModel = ShoppingListsViewModel(
        coordinator: AppCoordinator(dependencies: AppDependencies()),
        repository: MockShoppingListsRepository()
    )
    
    NavigationStack {
        ShoppingListsView(viewModel: mockViewModel)
    }
    .preferredColorScheme(.dark)
}
