//
//  StoreManager.swift
//  sweather-2
//
//  Created by Sam Davis on 6/5/20.
//  Copyright © 2020 Sam Davis. All rights reserved.
//

import Foundation
import StoreKit
import SwiftyStoreKit

enum IAPProductIds: String {
    case removeAds = "remove_ads"
}

extension SKProductSubscriptionPeriod {
    func prettyPrint() -> String {
        switch unit {
        case .day:
            return " per day"
        case .week:
            return " per week"
        case .month:
            return " per month"
        case .year:
            return " per year"
        @unknown default:
            return ""
        }
    }
}

extension SKProduct {
    /// - returns: The cost of the product formatted in the local currency.
    var regularPrice: String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = self.priceLocale
        return formatter.string(from: self.price)
    }
}

class StoreManager: ObservableObject {
    
    static var shared = StoreManager()
    
    @Published var products = [SKProduct]()
    @Published var adRemovalExpiry: Date?
    @Published var purchasing: Bool = false
    @Published var refreshing: Bool = false
    
    var adRemovealExpiryString: String {
        get {
            self.adRemovalExpiry != nil
                ? "Subscription expires:\n\(self.adRemovalExpiry!.prettyDateTime())"
                : "No active subscription"
        }
    }
    
    init() {
        print("Fetching products")
        SwiftyStoreKit.retrieveProductsInfo([IAPProductIds.removeAds.rawValue]) { (products) in
            DispatchQueue.main.async {
                self.products = Array(products.retrievedProducts)
                print("Fetched products")
            }
        }
    }
    
    // Should be called on app launch and after making/restoring purchases
    func verifyReciept() {
        let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: "b015ca428a4743fbbbfb28089338fbde")
        SwiftyStoreKit.verifyReceipt(using: appleValidator) { (result) in
            switch result {
            case .success(let receipt):
                let productId = IAPProductIds.removeAds.rawValue
                // Verify the purchase of a Subscription
                let purchaseResult = SwiftyStoreKit.verifySubscription(
                    ofType: .autoRenewable, // or .nonRenewing (see below)
                    productId: productId,
                    inReceipt: receipt)
                    
                switch purchaseResult {
                case .purchased(let expiryDate, let items):
                    print("\(productId) is valid until \(expiryDate)\n\(items)\n")
                    SessionData.shared.hasAdRemovalSubscription = true
                    self.adRemovalExpiry = expiryDate
                case .expired(let expiryDate, let items):
                    print("\(productId) is expired since \(expiryDate)\n\(items)\n")
                    SessionData.shared.hasAdRemovalSubscription = false
                case .notPurchased:
                    print("The user has never purchased \(productId)")
                    SessionData.shared.hasAdRemovalSubscription = false
                }

            case .error(let error):
                print("Receipt verification failed: \(error)")
            }
        }
    }
    
    func handleRemoveAds(product: SKProduct, onError: @escaping (String) -> Void) {
        self.purchasing = true
        SwiftyStoreKit.purchaseProduct(product) { (result: PurchaseResult) in
            self.purchasing = false
            switch result {
            case .success(let purchase):
                print("Purchase Success: \(purchase.productId)")
                self.verifyReciept()
            case .error(let error):
                switch error.code {
                case .unknown: onError("Unknown error. Please contact support")
                case .clientInvalid: onError("Not allowed to make the payment")
                case .paymentCancelled: onError("Payment cancelled")
                case .paymentInvalid: onError("The purchase identifier was invalid")
                case .paymentNotAllowed: onError("The device is not allowed to make the payment")
                case .storeProductNotAvailable: onError("The product is not available in the current storefront")
                case .cloudServicePermissionDenied: onError("Access to cloud service information is not allowed")
                case .cloudServiceNetworkConnectionFailed: onError("Could not connect to the network")
                case .cloudServiceRevoked: onError("User has revoked permission to use this cloud service")
                default: onError((error as NSError).localizedDescription)
                }
            }
        }
    }
    
    func handleRestore(onDone: @escaping (_ title: String, _ message: String) -> Void) {
        self.refreshing = true
        SwiftyStoreKit.restorePurchases(atomically: true) { results in
            self.refreshing = false
            if results.restoreFailedPurchases.count > 0 {
                onDone("Error", "Failed to restore purchases")
            }
            else if results.restoredPurchases.count > 0 {
                self.verifyReciept()
                onDone("Success", "Successfully restored purcahses")
            }
            else {
                onDone("Alert", "Nothing to Restore")
            }
        }
    }
}
