//
//  SessionData.swift
//  sweather-2
//
//  Created by Sam Davis on 29/10/19.
//  Copyright © 2019 Sam Davis. All rights reserved.
//

import Foundation



struct SessionData {
    
    enum SessionDataKeys: String {
        case currentWeatherLocation
        case viewingCurrentLocation
    }
    
    private static var defaults: UserDefaults {
        get {
            UserDefaults.standard
        }
    }
    
    static var currentLocationId: Int {
        get {
            defaults.integer(forKey: SessionDataKeys.currentWeatherLocation.rawValue)
        }
        set {
            defaults.set(newValue, forKey: SessionDataKeys.currentWeatherLocation.rawValue)
        }
    }
    
    static var viewingCurrentLocation: Bool {
        get {
            defaults.bool(forKey: SessionDataKeys.viewingCurrentLocation.rawValue)
        }
        set {
            defaults.set(newValue, forKey: SessionDataKeys.viewingCurrentLocation.rawValue)
        }
    }
}
