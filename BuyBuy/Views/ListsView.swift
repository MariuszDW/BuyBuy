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
    
    var designSystem: DesignSystem {
        return dependencies.designSystem
    }

    var body: some View {
        VStack {
            List {
                ForEach(viewModel.shoppingLists) { list in
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
                .onDelete { offsets in
                    viewModel.deleteLists(atOffsets: offsets)
                }
                .onMove { indices, newOffset in
                    viewModel.moveLists(fromOffsets: indices, toOffset: newOffset)
                }
            }

            HStack {
                Button(action: {
                    viewModel.addList()
                }) {
                    Label("Add", systemImage: "plus")
                }

                Spacer()

                EditButton()
            }
            .padding()
        }
        .navigationTitle("Shopping Lists")
    }
}

struct ListsView_Previews: PreviewProvider {
    static var previews: some View {
        let dependencies = AppDependencies()
        let mockViewModel = ListsViewModel(
            coordinator: AppCoordinator(dependencies: dependencies),
            repository: ListsRepository(store: dependencies.shoppingListStore)
        )

        Group {
            ListsView(viewModel: mockViewModel)
                .environmentObject(dependencies)
                .preferredColorScheme(.light)

            ListsView(viewModel: mockViewModel)
                .environmentObject(dependencies)
                .preferredColorScheme(.dark)
        }
    }
}

