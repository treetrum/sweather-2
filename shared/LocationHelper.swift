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
    var manager: CLLocationManager?

    func getLocation(completion: @escaping (CLLocation?) -> Void) {
        if let manager = self.manager {
            self.savedGetLocationCompletion = completion
            manager.delegate = self
            manager.requestWhenInUseAuthorization()
            manager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        manager.stopUpdatingLocation()
        guard let completion = self.savedGetLocationCompletion else {
            print("No completion handler saved");
            return;
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
