//
//  StoreObserver.swift
//  sweather-2
//
//  Created by Sam Davis on 3/5/20.
//  Copyright © 2020 Sam Davis. All rights reserved.
//

import Foundation
import StoreKit

class StoreObserver: NSObject, SKPaymentTransactionObserver, SKProductsRequestDelegate {
    
    static let shared = StoreObserver()
    
    var products = [SKProduct]()
    
    var isAuthorizedForPayments: Bool {
        return SKPaymentQueue.canMakePayments()
    }
    
    enum ProductIdentifiers: String {
        case removeAds = "remove_ads"
    }

    override init() {
        super.init()
        
        if self.isAuthorizedForPayments {
            print("IAP: Is authorized to make payments")
            fetchProducts(matchingIdentifiers: [ProductIdentifiers.removeAds.rawValue])
        }
        
    }

    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchasing: break
            // Do not block the UI. Allow the user to continue using the app.
            case .deferred: print("IAP: Transaction deferred")
            // The purchase was successful.
            case .purchased: handlePurchased(transaction)
            // The transaction failed.
            case .failed: handleFailed(transaction)
            // There're restored products.
            case .restored: handleRestored(transaction)
            @unknown default: fatalError("IAP: Unknown payment transaction")
            }
        }
    }
    
    func handlePurchased(_ transaction: SKPaymentTransaction) {
        print("IAP: Handling purchased");
        if (transaction.payment.productIdentifier == ProductIdentifiers.removeAds.rawValue) {
            
//            transaction.payment.
            
            SessionData.shared.hasAdRemovalSubscription = true
            SessionData.shared.adRemovalSubscripionExpiry = transaction.payment.productIdentifier
        }
        // Finish the successful transaction.
        SKPaymentQueue.default().finishTransaction(transaction)
        
    }
    
    func handleFailed(_ transaction: SKPaymentTransaction) {
        print("IAP: Handling failed");
        if let error = transaction.error {
            print("IAP: \(error.localizedDescription)")
        }
        // Finish the failed transaction.
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    func handleRestored(_ transaction: SKPaymentTransaction) {
        print("IAP: Handling restored");
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    func fetchProducts(matchingIdentifiers identifiers: [String]) {

        // Create a set for the product identifiers.
        let productIdentifiers = Set(identifiers)
        
        // Initialize the product request with the above identifiers.
        let productRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
        productRequest.delegate = self
        
        // Send the request to the App Store.
        print("IAP: Fetching products")
        productRequest.start()
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        if !response.products.isEmpty {
            print("IAP: Got product response")
            self.products = response.products
        }
    }
    
    func buy(_ product: SKProduct) {
        let payment = SKMutablePayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
                
}
