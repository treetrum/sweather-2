//
//  LocationHelper.swift
//  sweather-2
//
//  Created by Sam Davis on 19/9/20.
//  Copyright © 2020 Sam Davis. All rights reserved.
//

import Foundation
import CoreLocation
import AsyncLocationKit

class LocationHelper: NSObject, CLLocationManagerDelegate {
    
    static let shared = LocationHelper();
    
    var savedGetLocationCompletion: ((CLLocation?) async -> Void)?
    var manager: CLLocationManager?
    var lastCoords: CLLocation?
    var lastCoordsDate: Date = Date()

    func getLocation(completion: @escaping (CLLocation?) async -> Void) {
        
        guard let manager = self.manager else {
            print("LocationHelper didn't have a manager")
            return
        }
        
        self.savedGetLocationCompletion = completion
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        
        if let lastCoords = lastCoords {
            if lastCoordsDate.addingTimeInterval(900) < Date() { // 15 minute cache time
                Task {
                    await completion(lastCoords)
                }
            } else {
                manager.requestLocation()
            }
        } else {
            manager.requestLocation()
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
        Task {
            await completion(locations.first)
        }
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


struct AsyncLocationHelper {
    let manager: AsyncLocationManager

    func getLocation() async throws -> CLLocation? {
        switch try await manager.requestLocation() {
        case .didUpdateLocations(let locations):
            return locations.first
        case .didFailWith(error: let error):
            print(error.localizedDescription)
            return nil
        case .didResume, .didPaused, .none:
            return nil
        }
    }
}
