//
//  HomeView.swift
//  BuyBuy
//
//  Created by MDW on 14/05/2025.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: HomeViewModel

    var body: some View {
        VStack(spacing: 20) {
            Text("BuyBuy")
                .font(.largeTitle)

            Button("Przejdź do listy zakupów") {
                viewModel.createListTapped()
            }
        }
        .padding()
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        let mockCoordinator = AppCoordinator()
        let mockViewModel = HomeViewModel(coordinator: mockCoordinator)
        
        HomeView(viewModel: mockViewModel)
            .preferredColorScheme(.light)

        HomeView(viewModel: mockViewModel)
            .preferredColorScheme(.dark)
    }
}
