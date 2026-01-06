import Foundation
import StoreKit

/// Manages in-app subscriptions using StoreKit
@MainActor
final class SubscriptionService: ObservableObject {
    static let shared = SubscriptionService()

    // MARK: - Published Properties
    @Published var products: [Product] = []
    @Published var purchasedProductIDs: Set<String> = []
    @Published var isLoading = false
    @Published var error: SubscriptionError?

    // MARK: - Computed Properties
    var isPremium: Bool {
        !purchasedProductIDs.isEmpty
    }

    var monthlyProduct: Product? {
        products.first { $0.id == Constants.StoreKit.premiumMonthlyProductID }
    }

    // MARK: - Error Types
    enum SubscriptionError: LocalizedError {
        case productNotFound
        case purchaseFailed
        case verificationFailed
        case networkError

        var errorDescription: String? {
            switch self {
            case .productNotFound:
                return "Subscription product not found"
            case .purchaseFailed:
                return "Purchase failed. Please try again."
            case .verificationFailed:
                return "Purchase verification failed"
            case .networkError:
                return "Network error. Please check your connection."
            }
        }
    }

    // MARK: - Initialization
    private init() {
        Task {
            await loadProducts()
            await updatePurchasedProducts()
            await listenForTransactions()
        }
    }

    // MARK: - Product Loading

    /// Load available products from App Store
    func loadProducts() async {
        isLoading = true
        error = nil

        do {
            let productIDs = [
                Constants.StoreKit.premiumMonthlyProductID,
                Constants.StoreKit.premiumYearlyProductID
            ]

            products = try await Product.products(for: productIDs)

            if products.isEmpty {
                error = .productNotFound
            }
        } catch {
            self.error = .networkError
        }

        isLoading = false
    }

    // MARK: - Purchase

    /// Purchase a subscription product
    func purchase(_ product: Product) async -> Bool {
        isLoading = true
        error = nil

        do {
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await transaction.finish()
                await updatePurchasedProducts()
                updateUserPremiumStatus()
                isLoading = false
                return true

            case .userCancelled:
                isLoading = false
                return false

            case .pending:
                isLoading = false
                return false

            @unknown default:
                isLoading = false
                return false
            }
        } catch {
            self.error = .purchaseFailed
            isLoading = false
            return false
        }
    }

    /// Purchase premium monthly subscription
    func purchasePremium() async -> Bool {
        guard let product = monthlyProduct else {
            error = .productNotFound
            return false
        }

        return await purchase(product)
    }

    // MARK: - Restore Purchases

    /// Restore previous purchases
    func restorePurchases() async {
        isLoading = true
        error = nil

        do {
            try await AppStore.sync()
            await updatePurchasedProducts()
            updateUserPremiumStatus()
        } catch {
            self.error = .networkError
        }

        isLoading = false
    }

    // MARK: - Transaction Handling

    private func listenForTransactions() async {
        for await result in Transaction.updates {
            do {
                let transaction = try checkVerified(result)
                await updatePurchasedProducts()
                updateUserPremiumStatus()
                await transaction.finish()
            } catch {
                print("Transaction verification failed: \(error)")
            }
        }
    }

    private func updatePurchasedProducts() async {
        var purchased: Set<String> = []

        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)

                if transaction.revocationDate == nil {
                    purchased.insert(transaction.productID)
                }
            } catch {
                print("Failed to verify transaction: \(error)")
            }
        }

        purchasedProductIDs = purchased
    }

    private func checkVerified<T>(_ result: StoreKit.VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw SubscriptionError.verificationFailed
        case .verified(let safe):
            return safe
        }
    }

    private func updateUserPremiumStatus() {
        CoreDataManager.shared.setPremiumStatus(isPremium)
    }

    // MARK: - Subscription Info

    /// Get formatted price string
    func getPriceString() -> String {
        guard let product = monthlyProduct else {
            return "$2.99/month"
        }
        return product.displayPrice + "/month"
    }

    /// Get subscription status description
    func getStatusDescription() -> String {
        if isPremium {
            return "Premium - Unlimited unlocks"
        } else {
            return "Free - 15 unlocks/day"
        }
    }

    /// Check if user can access premium features
    func checkPremiumAccess() -> Bool {
        return isPremium || CoreDataManager.shared.currentUser.isPremium
    }
}

// MARK: - Product Extension
extension Product {
    var formattedDescription: String {
        switch id {
        case Constants.StoreKit.premiumMonthlyProductID:
            return "Unlimited daily unlocks, priority support"
        case Constants.StoreKit.premiumYearlyProductID:
            return "Unlimited daily unlocks, priority support, save 20%"
        default:
            return description
        }
    }
}
