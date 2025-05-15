//
//  ListsView.swift
//  BuyBuy
//
//  Created by MDW on 14/05/2025.
//

import SwiftUI

struct ListsView: View {
    @ObservedObject var viewModel: ListsViewModel

    var body: some View {
        List(viewModel.shoppingLists) { list in
            NavigationLink(value: AppRoute.shoppingListDetails(list.id)) {
                Text(list.name)
                    .foregroundColor(.primary)
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

struct ListsView_Previews: PreviewProvider {
    static var previews: some View {
        let mockViewModel = ListsViewModel(coordinator: AppCoordinator(), repository: ShoppingListRepository())

        Group {
            ListsView(viewModel: mockViewModel)
                .preferredColorScheme(.light)

            ListsView(viewModel: mockViewModel)
                .preferredColorScheme(.dark)
        }
    }
}
