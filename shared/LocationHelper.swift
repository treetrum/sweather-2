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
    var lastCoords: CLLocation?
    var lastCoordsDate: Date = Date()

    func getLocation(completion: @escaping (CLLocation?) -> Void) {
        if let manager = self.manager {
            self.savedGetLocationCompletion = completion
            manager.delegate = self
            manager.requestWhenInUseAuthorization()
            
            if let lastCoords = lastCoords {
                if lastCoordsDate.addingTimeInterval(900) < Date() { // 15 minute cache time
                    completion(lastCoords)
                } else {
                    manager.requestLocation()
                }
            } else {
                manager.requestLocation()
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        manager.stopUpdatingLocation()
        guard let completion = self.savedGetLocationCompletion else {
            print("No completion handler saved");
            return;
        }
        lastCoords = locations.first
        lastCoordsDate = Date()
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
