//
//  ShoppingListView.swift
//  BuyBuy
//
//  Created by MDW on 14/05/2025.
//

import SwiftUI

struct ShoppingListView: View {
    @ObservedObject var viewModel: ShoppingListViewModel

    var body: some View {
        VStack {
            Text("Lista zakupów")
                .font(.title)

            Button("Wróć") {
                viewModel.back()
            }
        }
        .padding()
    }
}

struct ShoppingListView_Previews: PreviewProvider {
    static var previews: some View {
        let mockCoordinator = AppCoordinator()
        let mockViewModel = ShoppingListViewModel(coordinator: mockCoordinator)
        
        ShoppingListView(viewModel: mockViewModel)
            .preferredColorScheme(.light)

        ShoppingListView(viewModel: mockViewModel)
            .preferredColorScheme(.dark)
    }
}
