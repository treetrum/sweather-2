//
//  SubscriptionsScreen.swift
//  sweather-2
//
//  Created by Sam Davis on 3/5/20.
//  Copyright © 2020 Sam Davis. All rights reserved.
//

import SwiftUI
import StoreKit
import SwiftyStoreKit

enum IAPProductIds: String {
    case removeAds = "remove_ads"
}

class StoreManager: ObservableObject {
    
    static var shared = StoreManager()
    
    @Published var products = [SKProduct]()
    @Published var adRemovalExpiry: Date?
    
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
}

struct SubscriptionsScreen: View {
//    var products = StoreManager.shared.
    @ObservedObject var storeManager = StoreManager.shared
    var body: some View {
        List {
            Section {
                if self.storeManager.products.count == 0 {
                    Text("Loading...")
                }
                ForEach(self.storeManager.products, id: \.productIdentifier) { (product: SKProduct) in
                    Button(action: {
                        print("IAP: Purchase: Remove ads clicked")
                        SwiftyStoreKit.purchaseProduct(product) { (result: PurchaseResult) in
                            switch result {
                            case .success(let purchase):
                                print("Purchase Success: \(purchase.productId)")
                                self.storeManager.verifyReciept()
                            case .error(let error):
                                switch error.code {
                                case .unknown: print("Unknown error. Please contact support")
                                case .clientInvalid: print("Not allowed to make the payment")
                                case .paymentCancelled: break
                                case .paymentInvalid: print("The purchase identifier was invalid")
                                case .paymentNotAllowed: print("The device is not allowed to make the payment")
                                case .storeProductNotAvailable: print("The product is not available in the current storefront")
                                case .cloudServicePermissionDenied: print("Access to cloud service information is not allowed")
                                case .cloudServiceNetworkConnectionFailed: print("Could not connect to the network")
                                case .cloudServiceRevoked: print("User has revoked permission to use this cloud service")
                                default: print((error as NSError).localizedDescription)
                                }
                            }
                        }
                    }) {
                        HStack {
                            Text(product.localizedTitle)
                            Spacer()
                            Text("\(product.regularPrice ?? "")\(product.subscriptionPeriod?.prettyPrint() ?? "")")
                        }
                    }.disabled(self.storeManager.adRemovalExpiry != nil)
                }
            }
            Section(footer:
                storeManager.adRemovalExpiry != nil
                    ? Text("Subscription expires:\n\(storeManager.adRemovalExpiry!.prettyDateTime())")
                    : Text("")
            ) {
                Button(action: {
                    print("IAP: Restore purchases clicked")
                    SwiftyStoreKit.restorePurchases(atomically: true) { results in
                        if results.restoreFailedPurchases.count > 0 {
                            print("Restore Failed: \(results.restoreFailedPurchases)")
                        }
                        else if results.restoredPurchases.count > 0 {
                            print("Restore Success: \(results.restoredPurchases)")
                            self.storeManager.verifyReciept()
                        }
                        else {
                            print("Nothing to Restore")
                        }
                    }
                }) {
                    HStack {
                        Text("Restore purcahses")
                    }
                }
            }
        }.listStyle(GroupedListStyle())
    }
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

struct SubscriptionsScreen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SubscriptionsScreen().navigationBarTitle(Text("Subscriptions"), displayMode: .inline)
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
