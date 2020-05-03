//
//  SessionData.swift
//  sweather-2
//
//  Created by Sam Davis on 29/10/19.
//  Copyright © 2019 Sam Davis. All rights reserved.
//

import Foundation
import Combine

class SessionData: ObservableObject {
    
    static let shared = SessionData()
    
    enum SessionDataKeys: String {
        case currentWeatherLocation
        case viewingCurrentLocation
        case hasAdRemovalSubscription
        case adRemovalSubscripionExpiry
    }
    
    @Published var currentLocationId: Int {
        didSet {
            UserDefaults.standard.set(self.currentLocationId, forKey: SessionDataKeys.currentWeatherLocation.rawValue)
        }
    }
    
    @Published var viewingCurrentLocation: Bool {
        didSet {
            UserDefaults.standard.set(viewingCurrentLocation, forKey: SessionDataKeys.viewingCurrentLocation.rawValue)
        }
    }
    
    @Published var hasAdRemovalSubscription: Bool {
        didSet {
            UserDefaults.standard.set(hasAdRemovalSubscription, forKey: SessionDataKeys.hasAdRemovalSubscription.rawValue)
        }
    }
    
    @Published var adRemovalSubscripionExpiry: String? {
        didSet {
            UserDefaults.standard.set(adRemovalSubscripionExpiry, forKey: SessionDataKeys.adRemovalSubscripionExpiry.rawValue)
        }
    }
    
    init(
        viewingCurrentLocation: Bool = UserDefaults.standard.bool(forKey: SessionDataKeys.viewingCurrentLocation.rawValue),
        currentLocationId: Int = UserDefaults.standard.integer(forKey: SessionDataKeys.currentWeatherLocation.rawValue),
        hasAdRemovalSubscription: Bool = UserDefaults.standard.bool(forKey: SessionDataKeys.hasAdRemovalSubscription.rawValue),
        adRemovalSubscripionExpiry: String? = UserDefaults.standard.string(forKey: SessionDataKeys.adRemovalSubscripionExpiry.rawValue)
    ) {
        self.currentLocationId = currentLocationId
        self.viewingCurrentLocation = viewingCurrentLocation
        self.hasAdRemovalSubscription = hasAdRemovalSubscription
        self.adRemovalSubscripionExpiry = adRemovalSubscripionExpiry
    }
}
