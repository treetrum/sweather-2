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
    
    enum SessionDataKeys: String {
        case currentWeatherLocation
        case viewingCurrentLocation
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
    
    init(
        viewingCurrentLocation: Bool = UserDefaults.standard.bool(forKey: SessionDataKeys.viewingCurrentLocation.rawValue),
        currentLocationId: Int = UserDefaults.standard.integer(forKey: SessionDataKeys.currentWeatherLocation.rawValue)
    ) {
        self.currentLocationId = currentLocationId
        self.viewingCurrentLocation = viewingCurrentLocation
    }
}
