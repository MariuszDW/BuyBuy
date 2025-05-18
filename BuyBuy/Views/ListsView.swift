//
//  ListsView.swift
//  BuyBuy
//
//  Created by MDW on 14/05/2025.
//

import SwiftUI

struct ListsView: View {
    @StateObject var viewModel: ListsViewModel
    @EnvironmentObject var dependencies: AppDependencies
    
    @State private var localEditMode: EditMode = .inactive
    @State private var listPendingDeletion: ShoppingList?
    
    var designSystem: DesignSystem {
        dependencies.designSystem
    }
    
    init(viewModel: ListsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack {
            lists
                .environment(\.editMode, $localEditMode)
            
            bottomPanel
        }
        .navigationTitle("Lists")
        .toolbar {
            toolbarContent
        }
        .onAppear {
            viewModel.loadLists()
        }
        .alert(item: $listPendingDeletion) { list in
            Alert(
                title: Text("Delete list \"\(list.name)\"?"),
                message: Text("This list contains items. Are you sure you want to delete it?"),
                primaryButton: .destructive(Text("Delete")) {
                    viewModel.deleteList(id: list.id)
                },
                secondaryButton: .cancel()
            )
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
                                        viewModel.startEditingList(list)
                                    } label: {
                                        Label("Edit", systemImage: "square.and.pencil")
                                    }
                                    
                                    Button(role: .destructive) {
                                        handleDeleteTapped(for: list)
                                    } label: {
                                        Label("Delete", systemImage: "trash.fill")
                                    }
                                }
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                handleDeleteTapped(for: list)
                            } label: {
                                Label("Delete", systemImage: "trash.fill")
                            }
                        }
                        .swipeActions(edge: .leading, allowsFullSwipe: false) {
                            Button {
                                viewModel.startEditingList(list)
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
                viewModel.deleteLists(atOffsets: offsets)
            }
            .onMove { indices, newOffset in
                viewModel.moveLists(fromOffsets: indices, toOffset: newOffset)
            }
        }
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
            
            Text("\(list.countItems(withStatus: .pending)) / \(list.countItems(withoutStatus: .inactive))")
                .foregroundColor(.secondary)
                .font(.subheadline)
        }
    }
    
    private var bottomPanel: some View {
        HStack {
            Button(action: {
                localEditMode = .inactive
                viewModel.startCreatingList()
            }) {
                Label("Add", systemImage: "plus.circle")
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
    
    private func handleDeleteTapped(for list: ShoppingList) {
        if list.items.isEmpty {
            viewModel.deleteList(id: list.id)
        } else {
            listPendingDeletion = list
        }
    }
}

// MARK: - Preview

#Preview("Light Mode") {
    let dependencies = AppDependencies()
    let mockViewModel = ListsViewModel(coordinator: AppCoordinator(dependencies: dependencies),
                                       repository: MockListsRepository())
    
    NavigationStack {
        ListsView(viewModel: mockViewModel)
    }
    .environmentObject(dependencies)
    .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    let dependencies = AppDependencies()
    let mockViewModel = ListsViewModel(coordinator: AppCoordinator(dependencies: dependencies),
                                       repository: MockListsRepository())
    
    NavigationStack {
        ListsView(viewModel: mockViewModel)
    }
    .environmentObject(dependencies)
    .preferredColorScheme(.dark)
}

// MARK: - Preview mock

class MockListsRepository: ListsRepositoryProtocol {
    func fetchAllLists() -> [ShoppingList] {
        return [
            ShoppingList(id: UUID(), name: "First list", items: [
                ShoppingItem(id: UUID(), name: "one", status: .pending),
                ShoppingItem(id: UUID(), name: "two", status: .purchased),
                ShoppingItem(id: UUID(), name: "three", status: .inactive),
                ShoppingItem(id: UUID(), name: "found", status: .pending)
            ], order: 0, icon: .clothes, color: .red),
            
            ShoppingList(id: UUID(), name: "Second list", items: [
                ShoppingItem(id: UUID(), name: "one", status: .purchased),
                ShoppingItem(id: UUID(), name: "two", status: .purchased),
                ShoppingItem(id: UUID(), name: "three", status: .pending),
                ShoppingItem(id: UUID(), name: "found", status: .purchased),
                ShoppingItem(id: UUID(), name: "found", status: .purchased)
            ], order: 1, icon: .fish, color: .green),
            
            ShoppingList(id: UUID(), name: "Third list", items: [], order: 2, icon: .car, color: .yellow)
        ]
    }
    
    func addList(_ list: ShoppingList) {}
    func deleteList(with id: UUID) {}
    func updateList(_ updatedList: ShoppingList) {}
}
