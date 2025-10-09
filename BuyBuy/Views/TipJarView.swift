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
            if let error = viewModel.error {
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
                    CircleIconView(systemName: "xmark")
                }
            }
        }
        .task {
            await viewModel.loadProducts()
            viewModel.tipJarPresenter()
        }
    }
    
    @ViewBuilder
    private var mainView: some View {
        GeometryReader { geometry in
            let iconSize = min(geometry.size.width * 0.7, geometry.size.height * 0.7)

            ZStack {
                OrientedContainerView(
                    isLandscape: geometry.size.isLandscape,
                    view1: mainIconView(iconSize: iconSize),
                    view2: mainContentView
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
                .blur(radius: viewModel.status == .processing ? 7 : 0)
                .animation(.easeInOut(duration: 0.3), value: viewModel.status)
                .allowsHitTesting(viewModel.status != .processing)

                if viewModel.status == .processing {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .controlSize(.large)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }
    }
    
    @ViewBuilder
    private func mainIconView(iconSize: CGFloat) -> some View {
        VStack(spacing: 16) {
            Image.bbTipJarImage
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: iconSize)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .black.opacity(0.7), radius: 6, y: 2)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.bb.text.secondary, lineWidth: 3)
                )
                .layoutPriority(0)

            VStack(spacing: 8) {
                Text("tip_jar_message")
                    .font(.regularDynamic(style: .footnote))
                    .foregroundColor(.bb.text.secondary)
                    .layoutPriority(1)

                Text("tip_jar_signature")
                    .font(.regularDynamic(style: .footnote))
                    .foregroundColor(.bb.text.secondary)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.trailing, iconSize * 0.15)
                    .layoutPriority(1)
            }
            .padding(.horizontal)
            .layoutPriority(1)
        }
    }
    
    @ViewBuilder
    private var mainContentView: some View {
        VStack {
            if viewModel.status == .loading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .controlSize(.large)
                    .frame(maxWidth: .infinity)
            } else {
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
                                .font(.regularDynamic(style: .footnote))
                                .foregroundColor(.bb.button.text.opacity(0.8))
                                .fixedSize(horizontal: false, vertical: true)
                                .multilineTextAlignment(.leading)
                        }
                    }
                    .buttonStyle(BBPlainButtonStyle())
                }
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
}

// MARK: - Preview

#Preview("Light") {
    let mockProducts: [TipProduct] = [
        TipProduct(id: "small_tip", name: "Coffee", price: "$1.99", description: "Coffee for the developer."),
        TipProduct(id: "medium_tip", name: "Large Coffee", price: "$2.99", description: "Large coffee for the developer."),
        TipProduct(id: "large_tip", name: "Coffe and Cake", price: "$4,99", description: "Coffee and cake for the developer.")
    ]
    
    let preferences = MockAppPreferences()
    let tracker = MockUserActivityTracker()
    let coordinator = AppCoordinator(preferences: preferences)
    let viewModel = TipJarViewModel(status: .ready,
                                    products: mockProducts,
                                    userActivityTracker: tracker,
                                    coordinator: coordinator)
    
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
    let tracker = MockUserActivityTracker()
    let coordinator = AppCoordinator(preferences: preferences)
    let viewModel = TipJarViewModel(status: .ready,
                                    products: mockProducts,
                                    userActivityTracker: tracker,
                                    coordinator: coordinator)
    
    TipJarView(viewModel: viewModel)
        .preferredColorScheme(.dark)
}

#Preview("Light/processing") {
    let mockProducts: [TipProduct] = [
        TipProduct(id: "small_tip", name: "Coffee", price: "$1.99", description: "Coffee for the developer."),
        TipProduct(id: "medium_tip", name: "Large Coffee", price: "$2.99", description: "Large coffee for the developer."),
        TipProduct(id: "large_tip", name: "Coffe and Cake", price: "$4,99", description: "Coffee and cake for the developer.")
    ]
    
    let preferences = MockAppPreferences()
    let tracker = MockUserActivityTracker()
    let coordinator = AppCoordinator(preferences: preferences)
    let viewModel = TipJarViewModel(status: .processing,
                                    products: mockProducts,
                                    userActivityTracker: tracker,
                                    coordinator: coordinator)
    
    TipJarView(viewModel: viewModel)
        .preferredColorScheme(.light)
}

#Preview("Dark/processing") {
    let mockProducts: [TipProduct] = [
        TipProduct(id: "small_tip", name: "Coffee", price: "$1.99", description: "Coffee for the developer."),
        TipProduct(id: "medium_tip", name: "Large Coffee", price: "$2.99", description: "Large coffee for the developer."),
        TipProduct(id: "large_tip", name: "Coffe and Cake", price: "$4,99", description: "Coffee and cake for the developer.")
    ]
    
    let preferences = MockAppPreferences()
    let tracker = MockUserActivityTracker()
    let coordinator = AppCoordinator(preferences: preferences)
    let viewModel = TipJarViewModel(status: .processing,
                                    products: mockProducts,
                                    userActivityTracker: tracker,
                                    coordinator: coordinator)
    
    TipJarView(viewModel: viewModel)
        .preferredColorScheme(.dark)
}

#Preview("Light/loading") {
    let mockProducts: [TipProduct] = [TipProduct(id: "x", name: "x", price: "x", description: "x")]
    let preferences = MockAppPreferences()
    let tracker = MockUserActivityTracker()
    let coordinator = AppCoordinator(preferences: preferences)
    let viewModel = TipJarViewModel(status: .loading,
                                    products: mockProducts,
                                    userActivityTracker: tracker,
                                    coordinator: coordinator)
    
    TipJarView(viewModel: viewModel)
        .preferredColorScheme(.light)
}

#Preview("Dark/loading") {
    let mockProducts: [TipProduct] = [TipProduct(id: "x", name: "x", price: "x", description: "x")]
    let preferences = MockAppPreferences()
    let tracker = MockUserActivityTracker()
    let coordinator = AppCoordinator(preferences: preferences)
    let viewModel = TipJarViewModel(status: .loading,
                                    products: mockProducts,
                                    userActivityTracker: tracker,
                                    coordinator: coordinator)
    
    TipJarView(viewModel: viewModel)
        .preferredColorScheme(.dark)
}

#Preview("Light/error") {
    let mockProducts: [TipProduct] = [TipProduct(id: "x", name: "x", price: "x", description: "x")]
    let preferences = MockAppPreferences()
    let tracker = MockUserActivityTracker()
    let coordinator = AppCoordinator(preferences: preferences)
    let viewModel = TipJarViewModel(error: "Mock test error message.",
                                    products: mockProducts,
                                    userActivityTracker: tracker,
                                    coordinator: coordinator)
    
    TipJarView(viewModel: viewModel)
        .preferredColorScheme(.light)
}

#Preview("Dark/error") {
    let mockProducts: [TipProduct] = [TipProduct(id: "x", name: "x", price: "x", description: "x")]
    let preferences = MockAppPreferences()
    let tracker = MockUserActivityTracker()
    let coordinator = AppCoordinator(preferences: preferences)
    let viewModel = TipJarViewModel(error: "Mock test error message.",
                                    products: mockProducts,
                                    userActivityTracker: tracker,
                                    coordinator: coordinator)
    TipJarView(viewModel: viewModel)
        .preferredColorScheme(.dark)
}
