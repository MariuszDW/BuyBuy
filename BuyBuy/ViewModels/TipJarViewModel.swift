//
//  TipJarViewModel.swift
//  BuyBuy
//
//  Created by MDW on 29/06/2025.
//

import Foundation
import StoreKit

struct TipProduct: Identifiable {
    let id: String
    let name: String
    let price: String
    let description: String
    let storeKitProduct: Product?
    
    init(storeKitProduct: Product) {
        self.id = storeKitProduct.id
        self.name = storeKitProduct.displayName
        self.price = storeKitProduct.displayPrice
        self.description = storeKitProduct.description
        self.storeKitProduct = storeKitProduct
    }
    
    init(id: String, name: String, price: String, description: String, storeKitProduct: Product? = nil) {
        self.id = id
        self.name = name
        self.price = price
        self.description = description
        self.storeKitProduct = storeKitProduct
    }
}

enum TipJarStatus {
    case ready
    case loading
    case processing
}

@MainActor
class TipJarViewModel: ObservableObject {
    private var coordinator: (any AppCoordinatorProtocol)?
    private var userActivityTracker: any UserActivityTrackerProtocol
    
    @Published var status: TipJarStatus = .loading
    @Published var error: String? = nil
    @Published var products: [TipProduct] = []
    @Published var inProgress: Bool = false
    
    init(userActivityTracker: any UserActivityTrackerProtocol, coordinator: any AppCoordinatorProtocol) {
        self.coordinator = coordinator
        self.userActivityTracker = userActivityTracker
    }
    
    convenience init(status: TipJarStatus = .ready,
                     error: String? = nil,
                     products: [TipProduct] = [],
                     userActivityTracker: any UserActivityTrackerProtocol,
                     coordinator: any AppCoordinatorProtocol
    ) {
        self.init(userActivityTracker: userActivityTracker, coordinator: coordinator)
        self.products = products
        self.status = status
        self.error = error
    }

    func loadProducts() async {
        guard !isMockData else { return }
        
        status = .loading
        defer { status = .ready }
        
        do {
            let storeKitProducts = try await Product.products(for: AppConstants.tipIDs)
            var tipProducts = storeKitProducts.map { TipProduct(storeKitProduct: $0) }
            
            tipProducts.sort { first, second in
                guard
                    let firstIndex = AppConstants.tipIDs.firstIndex(of: first.id),
                    let secondIndex = AppConstants.tipIDs.firstIndex(of: second.id)
                else {
                    return false
                }
                return firstIndex < secondIndex
            }
            
            products = tipProducts
        } catch {
            self.error = error.localizedDescription
            print("Failed to load tip products: \(error)")
        }
    }

    func purchase(_ product: TipProduct) async {
        status = .processing
        do {
            let result = try await product.storeKitProduct?.purchase()
            switch result {
            case .success(.verified(let transaction)):
                print("Verified transaction for: \(transaction.productID)")
                coordinator?.showThankYou(for: transaction, onDismiss: { _ in })
            case .userCancelled:
                print("User cancelled transaction")
                break
            case .pending:
                print("Pending transaction")
                break
            case .success(.unverified(let transaction, let error)):
                print("Unverified transaction for \(transaction.productID): \(error)")
            case .none:
                break
            @unknown default:
                break
            }
            status = .ready
        } catch {
            print("Purchase error: \(error)")
            status = .ready
        }
    }
    
    func tipJarPresenter() {
        userActivityTracker.lastTipJarShownDate = Date()
    }
    
    private var isMockData: Bool {
        return !products.isEmpty && products[0].storeKitProduct == nil
    }
}
