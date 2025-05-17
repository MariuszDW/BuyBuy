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
        .sheet(item: $viewModel.listBeingEditedOrCreated) { _ in
            editListSheet
        }
        .sheet(isPresented: $viewModel.isAboutPresented) {
            aboutSheet
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
                        NavigationLink(value: AppRoute.shoppingListDetails(list.id)) {
                            listRow(for: list)
                        }
                        .swipeActions {
                            Button {
                                viewModel.startEditingList(list)
                            } label: {
                                Label("Edit", systemImage: "square.and.pencil")
                            }
                            .tint(.blue)
                            
                            Button(role: .destructive) {
                                viewModel.deleteList(id: list.id)
                            } label: {
                                Label("Delete", systemImage: "trash.fill")
                            }
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
                .foregroundColor(.primary)
                .padding(.vertical, 8)
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
            }
            
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
    }
    
    private var editListSheet: some View {
        NavigationView {
            Form {
                TextField("List Name", text: Binding(
                    get: { viewModel.listBeingEditedOrCreated?.name ?? "" },
                    set: { viewModel.listBeingEditedOrCreated?.name = $0 }
                ))
                .font(designSystem.fonts.boldDynamic(style: .title2))
            }
            .navigationTitle(viewModel.listBeingEditedOrCreated?.name.isEmpty == true ? "New List" : "Edit List")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    viewModel.cancelEditing()
                },
                trailing: Button("OK") {
                    viewModel.confirmEditing()
                }
                .disabled((viewModel.listBeingEditedOrCreated?.name.trimmingCharacters(in: .whitespaces).isEmpty) ?? true)
            )
        }
    }
    
    private var aboutSheet: some View {
        NavigationView {
            VStack(spacing: 8) {
                Spacer()
                
                Text("BuyBuy")
                    .font(designSystem.fonts.boldDynamic(style: .title))
                
                Text(Bundle.main.appVersion)
                    .font(designSystem.fonts.regularDynamic(style: .footnote))
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("OK") {
                        viewModel.closeAbout()
                    }
                }
            }
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
