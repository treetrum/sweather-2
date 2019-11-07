//
//  WWDataManagers.swift
//  sweather-2
//
//  Created by Sam Davis on 29/10/19.
//  Copyright © 2019 Sam Davis. All rights reserved.
//

import Foundation
import CoreLocation
import SwiftUI

class LocationSearchManager: ObservableObject {

    let api = WillyWeatherAPI()

    @Published var results: [WWLocation] = []
    
    func search(query: String) {
        api.searchForLocationWithQuery(query: query) { (results, error) in
            guard let results = results else { return }
            DispatchQueue.main.async {
                self.results = results
                print("Got results \(results)")
            }
        }
    }
}

class WeatherDataManager: ObservableObject {
    private let api = WillyWeatherAPI()
    private let locationId: Int
    
    @Published var weatherData: WWWeatherData?
    
    init(locationId: Int) {
        self.locationId = locationId
        getWeatherData()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.getWeatherData),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }
    
    func destroy() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func getWeatherData() {
        api.getWeatherForLocation(location: locationId) { (weatherData, error) in
            guard let weatherData = weatherData else { return }
            DispatchQueue.main.async {
                self.weatherData = weatherData
            }
        }
    }
}

class CurrentLocationWeatherDataManager: NSObject, CLLocationManagerDelegate, ObservableObject {
    
    private let manager = CLLocationManager()
    private let api = WillyWeatherAPI()
    private var observer: Any?

    @Published var location: WWLocation?
    
    override init() {
        super.init()
        manager.delegate = self
        self.getLocation()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.getLocation),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }
    
    func destroy() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func getLocation() {
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
    
    func getLocationForCoords(_ coords: CLLocationCoordinate2D) {
        api.getLocationForCoords(coords: coords) { (results, error) in
            guard let results = results else { return }
            DispatchQueue.main.async {
                self.location = results
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let first = locations.first {
            getLocationForCoords(first.coordinate)
            manager.stopUpdatingLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
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

