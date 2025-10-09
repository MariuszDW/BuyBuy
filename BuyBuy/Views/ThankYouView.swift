//
//  ThankYouView.swift
//  BuyBuy
//
//  Created by MDW on 30/06/2025.
//

import SwiftUI

struct ThankYouView: View {
    @StateObject var viewModel: ThankYouViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(viewModel: ThankYouViewModel) {
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
        .task {
            await viewModel.loadProduct()
            viewModel.thankYouPresenter()
        }
    }
    
    @ViewBuilder
    private var mainView: some View {
        GeometryReader { geometry in
            let iconSize = min(geometry.size.width * 0.7, geometry.size.height * 0.7)
            let coffeeImageSize = iconSize * 0.3
            
            OrientedContainerView(
                isLandscape: geometry.size.isLandscape,
                view1: mainIconView(iconSize: iconSize),
                view2: mainContentView(iconSize: coffeeImageSize)
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
        }
    }
    
    @ViewBuilder
    private func mainIconView(iconSize: CGFloat) -> some View {
        viewModel.thankYouImage
            .resizable()
            .scaledToFit()
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.7), radius: 6, y: 2)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.bb.text.secondary, lineWidth: 3)
            )
            .frame(maxWidth: iconSize)
    }
    
    @ViewBuilder
    private func mainContentView(iconSize: CGFloat) -> some View {
        VStack(spacing: 48) {
            HStack(spacing: 8) {
                ForEach(0..<viewModel.coffeeCount, id: \.self) { _ in
                    Image(systemName: "cup.and.saucer.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: iconSize)
                        .foregroundColor(.bb.text.tertiary)
                }
            }
            
            VStack(alignment: .center, spacing: 24) {
                let productName = viewModel.productName ?? String(localized: "tip")
                Text(productName)
                    .font(.boldDynamic(style: .title))
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.center)
                
                let productDescription = viewModel.productDescription ?? String(localized: "thank_you_for_support")
                Text(productDescription)
                    .font(.semiboldDynamic(style: .title3))
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.center)
            }
            
            Button {
                dismiss()
            } label: {
                Label("close", systemImage: "hand.thumbsup.fill")
            }
            .buttonStyle(BBPlainButtonStyle())
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
            
            Button {
                dismiss()
            } label: {
                Label("close", systemImage: "hand.thumbsdown.fill")
            }
            .buttonStyle(BBPlainButtonStyle())
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
    let coordinator = AppCoordinator(preferences: MockAppPreferences())
    let tracker = MockUserActivityTracker()
    let viewModel = ThankYouViewModel(
        productID: "large_tip",
        productName: "Large Tip",
        productDescription: "Thank you for the huge support!",
        loading: false,
        userActivityTracker: tracker,
        coordinator: coordinator)
    
    ThankYouView(viewModel: viewModel)
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    let coordinator = AppCoordinator(preferences: MockAppPreferences())
    let tracker = MockUserActivityTracker()
    let viewModel = ThankYouViewModel(
        productID: "large_tip",
        productName: "Large Tip",
        productDescription: "Thank you for the huge support!",
        loading: false,
        userActivityTracker: tracker,
        coordinator: coordinator)
    
    ThankYouView(viewModel: viewModel)
        .preferredColorScheme(.dark)
}

#Preview("Light/loading") {
    let coordinator = AppCoordinator(preferences: MockAppPreferences())
    let tracker = MockUserActivityTracker()
    let viewModel = ThankYouViewModel(
        productID: "large_tip",
        loading: true,
        userActivityTracker: tracker,
        coordinator: coordinator)
    
    ThankYouView(viewModel: viewModel)
        .preferredColorScheme(.light)
}

#Preview("Dark/loading") {
    let coordinator = AppCoordinator(preferences: MockAppPreferences())
    let tracker = MockUserActivityTracker()
    let viewModel = ThankYouViewModel(
        productID: "large_tip",
        loading: true,
        userActivityTracker: tracker,
        coordinator: coordinator)
    
    ThankYouView(viewModel: viewModel)
        .preferredColorScheme(.dark)
}

#Preview("Light/error") {
    let coordinator = AppCoordinator(preferences: MockAppPreferences())
    let tracker = MockUserActivityTracker()
    let viewModel = ThankYouViewModel(
        productID: "large_tip",
        loading: false,
        error: "Test error message.",
        userActivityTracker: tracker,
        coordinator: coordinator)
    
    ThankYouView(viewModel: viewModel)
        .preferredColorScheme(.light)
}

#Preview("Dark/error") {
    let coordinator = AppCoordinator(preferences: MockAppPreferences())
    let tracker = MockUserActivityTracker()
    let viewModel = ThankYouViewModel(
        productID: "large_tip",
        loading: false,
        error: "Test error message.",
        userActivityTracker: tracker,
        coordinator: coordinator)
    
    ThankYouView(viewModel: viewModel)
        .preferredColorScheme(.dark)
}
