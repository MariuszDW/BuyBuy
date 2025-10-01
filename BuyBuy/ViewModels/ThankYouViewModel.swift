//
//  ThankYouViewModel.swift
//  BuyBuy
//
//  Created by MDW on 30/06/2025.
//

import SwiftUI
import StoreKit

@MainActor
final class ThankYouViewModel: ObservableObject {
    private var coordinator: (any AppCoordinatorProtocol)?
    private var userActivityTracker: any UserActivityTrackerProtocol
    private var transaction: StoreKit.Transaction? = nil
    private var productID: String
    
    var productName: String?
    var productDescription: String?
    var error: String? = nil
    
    @Published var loading: Bool = true
    
    var coffeeCount: Int {
        switch productID {
        case AppConstants.tipIDs[0]: return 1
        case AppConstants.tipIDs[1]: return 2
        case AppConstants.tipIDs[2]: return 3
        default: return 1
        }
    }
    
    var thankYouImage: Image {
        switch productID {
        case AppConstants.tipIDs[0]: return Image.bbSmallTipImage
        case AppConstants.tipIDs[1]: return Image.bbMediumTipImage
        case AppConstants.tipIDs[2]: return Image.bbLargeTipImage
        default: return Image.bbSmallTipImage
        }
    }
    
    init(transaction: StoreKit.Transaction?,
         userActivityTracker: any UserActivityTrackerProtocol,
         coordinator: any AppCoordinatorProtocol) {
        self.transaction = transaction
        self.coordinator = coordinator
        self.userActivityTracker = userActivityTracker
        self.productID = transaction?.productID ?? AppConstants.tipIDs[0]
    }
    
    convenience init(productID: String,
                     productName: String? = nil,
                     productDescription: String? = nil,
                     loading: Bool = false,
                     error: String? = nil,
                     userActivityTracker: any UserActivityTrackerProtocol,
                     coordinator: any AppCoordinatorProtocol
    ) {
        self.init(transaction: nil, userActivityTracker: userActivityTracker, coordinator: coordinator)
        self.productID = productID
        self.productName = productName
        self.productDescription = productDescription
        self.loading = loading
        self.error = error
    }
    
    func loadProduct() async {
        guard !isMockData else { return }
        
        loading = true
        defer { loading = false }
        
        do {
            if let transaction = transaction, let product = try await Product.products(for: [productID]).first {
                productName = product.displayName
                productDescription = product.description
                await transaction.finish()
            } else {
                error = String(localized: "unknown_error")
            }
        } catch {
            self.error = error.localizedDescription
            AppLogger.general.error("Failed to load tip info: \(error, privacy: .public)")
        }
    }
    
    func thankYouPresenter() {
        userActivityTracker.incrementTipCount(for: productID)
    }
    
    private var isMockData: Bool {
        transaction == nil
    }
}
