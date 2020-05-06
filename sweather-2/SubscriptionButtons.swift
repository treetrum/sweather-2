//
//  SubscriptionButtons.swift
//  sweather-2
//
//  Created by Sam Davis on 3/5/20.
//  Copyright © 2020 Sam Davis. All rights reserved.
//

import SwiftUI
import StoreKit
import SwiftyStoreKit

struct SubscriptionButtons: View {

    @ObservedObject var storeManager = StoreManager.shared
    
    var loadingText: Text = {
        Text("Loading...")
    }()
    
    @State var alertTitle = ""
    @State var alertMessage = ""
    @State var showingAlert = false
    
    var body: some View {
        Section(footer: Text(self.storeManager.adRemovealExpiryString)) {
            if self.storeManager.products.count == 0 {
                self.loadingText
            }
            ForEach(self.storeManager.products, id: \.productIdentifier) { (product: SKProduct) in
                Button(action: {
                    self.storeManager.handleRemoveAds(product: product, onError: { message in
                        self.alertTitle = "Error"
                        self.alertMessage = message
                        self.showingAlert = true
                    })
                }) {
                    HStack {
                        NavigationButtonIcon(iconName: "nosign", colour: .green)
                        if (self.storeManager.purchasing) {
                            self.loadingText
                        } else {
                            Text(product.localizedTitle)
                            Spacer()
                            Text("\(product.regularPrice ?? "")\(product.subscriptionPeriod?.prettyPrint() ?? "")")
                        }
                        
                    }
                }
                .disabled(self.storeManager.adRemovalExpiry != nil)
            }
            Button(action: {
                self.storeManager.handleRestore { (title, message) in
                    self.showingAlert = true
                    self.alertTitle = title
                    self.alertMessage = message
                }
            }) {
                HStack {
                    NavigationButtonIcon(iconName: "arrow.2.circlepath", colour: .yellow)
                    if (self.storeManager.refreshing) {
                        self.loadingText
                    } else {
                        Text("Restore purcahses")
                    }
                }
                
            }
        }
        .alert(isPresented: self.$showingAlert) { () -> Alert in
            Alert(
                title: Text(self.alertTitle),
                message: Text(self.alertMessage),
                dismissButton: .default(Text("Got it!"))
            )
        }
    }
}

struct SubscriptionButtons_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            List {
                SubscriptionButtons()
            }.listStyle(GroupedListStyle())
        }
    }
}

