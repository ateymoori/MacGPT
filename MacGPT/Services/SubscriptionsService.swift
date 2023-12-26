//
//  SubscriptionsService.swift
//  iLexicon
//
//  Created by Amirhossein Teymoori on 2023-12-23.
//

import StoreKit

class SubscriptionsService: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    static let shared = SubscriptionsService()
    var products: [SKProduct] = []
    
    override init() {
        super.init()
        SKPaymentQueue.default().add(self)
        print("SubscriptionsService initialized")
    }

    func requestProducts() {
        let productIdentifiers: Set<String> = ["monthly30days"] // Replace with your actual product IDs
        let request = SKProductsRequest(productIdentifiers: productIdentifiers)
        request.delegate = self
        request.start()
        print("Requested products from App Store")

    }

    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        products = response.products
        // Notify via NotificationCenter or a custom delegate that product information is available
        // Alternatively, use Combine or another reactive framework if your project already uses one
        print("Received products: \(products.map { $0.localizedTitle })")

    }

    func buyProduct(_ product: SKProduct) {
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
        print("Started purchase process for product: \(product.localizedTitle)")

    }

    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
                case .purchased, .restored:
                    print("Purchase or restore successful for transaction: \(transaction.transactionIdentifier ?? "")")
                    complete(transaction: transaction)
                case .failed:
                    print("Purchase failed for transaction: \(transaction.transactionIdentifier ?? "") - Error: \(transaction.error?.localizedDescription ?? "Unknown error")")
                    fail(transaction: transaction)
                default:
                    print("Transaction state updated: \(transaction.transactionState.rawValue)")
                    break
            }
        }
    }

    private func complete(transaction: SKPaymentTransaction) {
        SKPaymentQueue.default().finishTransaction(transaction)
        print("Completed transaction: \(transaction.transactionIdentifier ?? "")")
    }

    private func fail(transaction: SKPaymentTransaction) {
        SKPaymentQueue.default().finishTransaction(transaction)
        print("Failed transaction: \(transaction.transactionIdentifier ?? "")")
    }

    deinit {
        SKPaymentQueue.default().remove(self)
        print("SubscriptionsService deinitialized")
    }

    func restorePurchases() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
}

