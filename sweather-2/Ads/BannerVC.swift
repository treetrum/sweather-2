//
//  BannerVC.swift
//  sweather-2
//
//  Created by Sam Davis on 3/5/20.
//  Copyright © 2020 Sam Davis. All rights reserved.
//

import SwiftUI
import GoogleMobileAds
import UIKit

struct AdBanner: View {
    @ObservedObject var sessionData = SessionData.shared
    
    var body: some View {
        VStack {
            if Features.isAdsFeatureEnabled {
                if self.sessionData.hasAdRemovalSubscription || self.sessionData.forceNoAds {
                    EmptyView()
                } else {
                    HStack {
                        Spacer(minLength: 0)
                        Banner().frame(width: kGADAdSizeBanner.size.width, height: kGADAdSizeBanner.size.height)
                        Spacer(minLength: 0)
                    }
                }
            } else {
                EmptyView()
            }
        }
    }
}

struct Banner: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let view = GADBannerView(adSize: kGADAdSizeBanner)
        let viewController = UIViewController()
        
        #if DEBUG
        view.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        #else
        view.adUnitID = "ca-app-pub-7736556580630436/6484370611"
        #endif
        
        view.rootViewController = viewController
        viewController.view.addSubview(view)
        viewController.view.frame = CGRect(
            origin: .zero,
            size: kGADAdSizeBanner.size
        )
        view.load(GADRequest())
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

struct Banner_Previews: PreviewProvider {
    static var previews: some View {
        Banner()
    }
}
