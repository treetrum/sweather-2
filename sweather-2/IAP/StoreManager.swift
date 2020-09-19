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
import TPInAppReceipt

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
    
    var adRemovalExpiryString: String {
        get {
            self.adRemovalExpiry != nil
                ? "Subscription expires:\n\(self.adRemovalExpiry!.prettyDateTime())"
                : "No active subscription"
        }
    }
    
    init() {
        print("[StoreManager] Fetching products")
        SwiftyStoreKit.retrieveProductsInfo([IAPProductIds.removeAds.rawValue]) { (products) in
            DispatchQueue.main.async {
                self.products = Array(products.retrievedProducts)
                print("[StoreManager] Fetched products")
            }
        }
    }
    
    /// Should be called on app launch and after making/restoring purchases
    /// Handles the fetching and subsequently, the verification of the receipt
    func verifyReciept() {
        // get the receipt from SwiftyStoreKit and validate
        if let receiptData = SwiftyStoreKit.localReceiptData {
            do {
                let receipt = try InAppReceipt.receipt(from: receiptData)
                validateReceipt(receipt: receipt)
            }
            catch {
                print("[StoreManager] Error creating receipt from data")
            }
        }
        else {
            //no receipt, hence force a refresh
            SwiftyStoreKit.fetchReceipt(forceRefresh: true) { result in
                switch result {
                case .success(let receiptData):
                    do {
                        let receipt = try InAppReceipt.receipt(from: receiptData)
                        self.validateReceipt(receipt: receipt)
                    }
                    catch {
                        print("[StoreManager] Error validating receipt")
                    }
                case .error(let error):
                    print("[StoreManager] Error fetching receipt \(error)")
                }
            }
        }
    }
    
    /// Handles the actual verification of the receipt
    func validateReceipt(receipt:InAppReceipt) {
        do {
            try receipt.verify()
        } catch IARError.validationFailed(reason: .hashValidation) {
            // TODO: Handle error
        } catch IARError.validationFailed(reason: .bundleIdentifierVefirication) {
            // TODO: Handle error
        } catch IARError.validationFailed(reason: .signatureValidation) {
            // TODO: Handle error
        } catch {
            // TODO: Handle error
        }
        
        let activePurchases: [InAppPurchase] = receipt.activeAutoRenewableSubscriptionPurchases

        if activePurchases.isEmpty {
            self.adRemovalExpiry = nil;
            SessionData.shared.hasAdRemovalSubscription = false
        } else {
            for purchase in activePurchases {
                if purchase.productIdentifier == IAPProductIds.removeAds.rawValue {
                    SessionData.shared.hasAdRemovalSubscription = true
                    self.adRemovalExpiry = purchase.subscriptionExpirationDate
                }
            }
        }
    }
    
    func handleRemoveAds(product: SKProduct, onError: @escaping (String) -> Void) {
        self.purchasing = true
        SwiftyStoreKit.purchaseProduct(product) { (result: PurchaseResult) in
            self.purchasing = false
            switch result {
            case .success(let purchase):
                print("[StoreManager] Purchase Success: \(purchase.productId)")
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
