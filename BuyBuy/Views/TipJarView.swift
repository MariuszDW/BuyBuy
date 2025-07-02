//
//  TipJarView.swift
//  BuyBuy
//
//  Created by MDW on 29/06/2025.
//

import SwiftUI

struct TipJarView: View {
    @StateObject var viewModel: TipJarViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(viewModel: TipJarViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        Group {
            if viewModel.loading == true {
                loadingView
            } else if let error = viewModel.error {
                errorView(error: error)
            } else {
                mainView
            }
        }
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle")
                }
            }
        }
        .task {
            await viewModel.loadProducts()
        }
    }
    
    @ViewBuilder
    private var mainView: some View {
        GeometryReader { geometry in
            let iconSize =  min(geometry.size.width * 0.5, geometry.size.height * 0.5)
            
            OrientedContainerView(
                isLandscape: geometry.size.isLandscape,
                view1: mainIconView(iconSize: iconSize),
                view2: mainContentView
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
        }
    }
    
    @ViewBuilder
    private func mainIconView(iconSize: CGFloat) -> some View {
        Image(systemName: "cup.and.saucer.fill")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .foregroundStyle(.green)
            .frame(maxWidth: iconSize)
    }
    
    @ViewBuilder
    private var mainContentView: some View {
        VStack {
            ForEach(viewModel.products, id: \.id) { product in
                Button {
                    Task {
                        await viewModel.purchase(product)
                    }
                } label: {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(product.name)
                                .font(.boldDynamic(style: .headline))
                                .foregroundColor(.bb.button.text)
                                .fixedSize(horizontal: false, vertical: true)
                                .multilineTextAlignment(.leading)
                            
                            Spacer()
                            
                            Text(product.price)
                                .font(.boldDynamic(style: .headline))
                                .foregroundColor(.yellow)
                        }
                        
                        Text(product.description)
                            .font(.regularDynamic(style: .callout))
                            .foregroundColor(.bb.button.text.opacity(0.8))
                            .fixedSize(horizontal: false, vertical: true)
                            .multilineTextAlignment(.leading)
                    }
                }
                .buttonStyle(BBPlainButtonStyle())
            }
        }
        .padding(4)
    }
    
    @ViewBuilder
    private func errorView(error: String) -> some View {
        GeometryReader { geometry in
            let iconSize =  min(geometry.size.width * 0.5, geometry.size.height * 0.5)
            
            OrientedContainerView(
                isLandscape: geometry.size.isLandscape,
                view1: errorIconView(iconSize: iconSize),
                view2: errorContentView
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
        }
    }
    
    @ViewBuilder
    private func errorIconView(iconSize: CGFloat) -> some View {
        Image(systemName: "exclamationmark.circle")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .foregroundStyle(.red)
            .frame(maxWidth: iconSize)
    }
    
    @ViewBuilder
    private var errorContentView: some View {
        VStack(spacing: 64) {
            VStack(alignment: .center, spacing: 24) {
                Text("something_went_wrong")
                    .font(.boldDynamic(style: .title))
                    .fixedSize(horizontal: false, vertical: true)
                
                if let error = viewModel.error {
                    Text(error)
                        .font(.semiboldDynamic(style: .title3))
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.center)
                }
            }
        }
    }
    
    @ViewBuilder
    private var loadingView: some View {
        VStack {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .controlSize(.large)
                .frame(maxWidth: .infinity)
        }
        .padding()
    }
}

// MARK: - Preview

#Preview("Light") {
    let mockProducts: [TipProduct] = [
        TipProduct(id: "small_tip", name: "Coffee", price: "$1.99", description: "Coffee for the developer."),
        TipProduct(id: "medium_tip", name: "Large Coffee", price: "$2.99", description: "Large coffee for the developer."),
        TipProduct(id: "large_tip", name: "Coffe and Cake", price: "$4,99", description: "Coffee and cake for the developer.")
    ]
    
    let preferences = MockAppPreferences()
    let coordinator = AppCoordinator(preferences: preferences)
    let viewModel = TipJarViewModel(loading: false, products: mockProducts, coordinator: coordinator)
    
    TipJarView(viewModel: viewModel)
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    let mockProducts: [TipProduct] = [
        TipProduct(id: "small_tip", name: "Coffee", price: "$1.99", description: "Coffee for the developer."),
        TipProduct(id: "medium_tip", name: "Large Coffee", price: "$2.99", description: "Large coffee for the developer."),
        TipProduct(id: "large_tip", name: "Coffe and Cake", price: "$4,99", description: "Coffee and cake for the developer.")
    ]
    
    let preferences = MockAppPreferences()
    let coordinator = AppCoordinator(preferences: preferences)
    let viewModel = TipJarViewModel(loading: false, products: mockProducts, coordinator: coordinator)
    
    TipJarView(viewModel: viewModel)
        .preferredColorScheme(.dark)
}

#Preview("Light/loading") {
    let mockProducts: [TipProduct] = [TipProduct(id: "x", name: "x", price: "x", description: "x")]
    let preferences = MockAppPreferences()
    let coordinator = AppCoordinator(preferences: preferences)
    let viewModel = TipJarViewModel(loading: true, products: mockProducts, coordinator: coordinator)
    
    TipJarView(viewModel: viewModel)
        .preferredColorScheme(.light)
}

#Preview("Dark/loading") {
    let mockProducts: [TipProduct] = [TipProduct(id: "x", name: "x", price: "x", description: "x")]
    let preferences = MockAppPreferences()
    let coordinator = AppCoordinator(preferences: preferences)
    let viewModel = TipJarViewModel(loading: true, products: mockProducts, coordinator: coordinator)
    
    TipJarView(viewModel: viewModel)
        .preferredColorScheme(.dark)
}

#Preview("Light/error") {
    let mockProducts: [TipProduct] = [TipProduct(id: "x", name: "x", price: "x", description: "x")]
    let preferences = MockAppPreferences()
    let coordinator = AppCoordinator(preferences: preferences)
    let viewModel = TipJarViewModel(error: "Mock test error message.", products: mockProducts, coordinator: coordinator)
    
    TipJarView(viewModel: viewModel)
        .preferredColorScheme(.light)
}

#Preview("Dark/error") {
    let mockProducts: [TipProduct] = [TipProduct(id: "x", name: "x", price: "x", description: "x")]
    let preferences = MockAppPreferences()
    let coordinator = AppCoordinator(preferences: preferences)
    let viewModel = TipJarViewModel(error: "Mock test error message.", products: mockProducts, coordinator: coordinator)
    
    TipJarView(viewModel: viewModel)
        .preferredColorScheme(.dark)
}
