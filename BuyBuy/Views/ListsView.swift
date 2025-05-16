//
//  ListsView.swift
//  BuyBuy
//
//  Created by MDW on 14/05/2025.
//

import SwiftUI

struct ListsView: View {
    @ObservedObject var viewModel: ListsViewModel
    @EnvironmentObject var dependencies: AppDependencies
    
    @State private var localEditMode: EditMode = .inactive
    
    var designSystem: DesignSystem {
        dependencies.designSystem
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
        .sheet(isPresented: $viewModel.isPresentingNewListSheet) {
            newListSheet
        }
    }
    
    // MARK: - Subviews
    
    private var lists: some View {
        List {
            ForEach(viewModel.shoppingLists) { list in
                Group {
                    if localEditMode.isEditing {
                        Text(list.name)
                            .foregroundColor(.primary)
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    } else {
                        NavigationLink(value: AppRoute.shoppingListDetails(list.id)) {
                            Text(list.name)
                                .foregroundColor(.primary)
                                .padding(.vertical, 8)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .swipeActions {
                            Button(role: .destructive) {
                                viewModel.deleteList(id: list.id)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
            }
            .onDelete { offsets in
                viewModel.deleteLists(atOffsets: offsets)
            }
            .onMove { indices, newOffset in
                viewModel.moveLists(fromOffsets: indices, toOffset: newOffset)
            }
        }
    }
    
    private var bottomPanel: some View {
        HStack {
            Button(action: {
                localEditMode = .inactive
                viewModel.startCreatingNewList()
            }) {
                Label("Add", systemImage: "plus.circle")
            }
            .disabled(localEditMode.isEditing)
            
            Spacer()
        }
        .padding()
    }
    
    private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarTrailing) {
            Button {
                withAnimation {
                    if localEditMode == .active {
                        localEditMode = .inactive
                    } else {
                        localEditMode = .active
                    }
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
    
    private var newListSheet: some View {
        NavigationView {
            Form {
                TextField("List Name", text: $viewModel.newListName)
            }
            .navigationTitle("New List")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    viewModel.cancelNewList()
                },
                trailing: Button("OK") {
                    viewModel.confirmNewList()
                }.disabled(viewModel.newListName.trimmingCharacters(in: .whitespaces).isEmpty)
            )
        }
    }

}

// MARK: - Preview

struct ListsView_Previews: PreviewProvider {
    static var previews: some View {
        let dependencies = AppDependencies()
        let mockViewModel = ListsViewModel(
            coordinator: AppCoordinator(dependencies: dependencies),
            repository: ListsRepository(store: dependencies.shoppingListStore)
        )
        
        Group {
            NavigationStack {
                ListsView(viewModel: mockViewModel)
                    .environmentObject(dependencies)
            }
            .preferredColorScheme(.light)
            
            NavigationStack {
                ListsView(viewModel: mockViewModel)
                    .environmentObject(dependencies)
            }
            .preferredColorScheme(.dark)
        }
    }
}
