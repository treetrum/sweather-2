//
//  LocationHelper.swift
//  sweather-2
//
//  Created by Sam Davis on 19/9/20.
//  Copyright © 2020 Sam Davis. All rights reserved.
//

import Foundation
import CoreLocation

class LocationHelper: NSObject, CLLocationManagerDelegate {
    
    static let shared = LocationHelper();
    
    var savedGetLocationCompletion: ((CLLocation?) -> Void)?
    let manager = CLLocationManager()
    
    override init() {
        super.init()
        manager.delegate = self
    }
    
    func getLocation(completion: @escaping (CLLocation?) -> Void) {
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        self.savedGetLocationCompletion = completion
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let completion = self.savedGetLocationCompletion else {
            fatalError("No completion handler saved");
        }
        completion(locations.first)
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            manager.requestLocation()
        } else {
            print("Did not authorize")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        return
    }
}
