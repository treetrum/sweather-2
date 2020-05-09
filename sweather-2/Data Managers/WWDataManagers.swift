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
import Combine

class MapDataManager: ObservableObject {
    let api = WillyWeatherAPI()
    
    @Published var loading = false
    @Published var images = [Int: UIImage]()
    @Published var mapData: WWMapData? {
        didSet {
            self.images = [Int: UIImage]()
            if let data = self.mapData {
                for (index, overlay) in data.overlays.enumerated() {
                    let urlString = "\(data.overlayPath)\(overlay.name)"
                    MapView.getImageAsync(urlString) { (image) in
                        self.images[index] = image
                    }
                }
            }
        }
    }
    
    init(locationId: Int) {
        self.loading = true
        api.getMapsForLocatoin(location: locationId) { (mapData, error) in
            guard let mapData = mapData else { return }
            DispatchQueue.main.async {
                self.mapData = mapData
                self.loading = false
            }
        }
    }
}

class LocationSearchManager: ObservableObject {

    let api = WillyWeatherAPI()

    @Published var results: [WWLocation] = []
    @Published var inputValue = ""
    
    private var cancellable: AnyCancellable? = nil
    
    init() {
        cancellable = AnyCancellable(
            $inputValue
                .removeDuplicates()
                .debounce(for: 0.25, scheduler: DispatchQueue.main)
                .sink(receiveValue: { (value) in
                    if value == "" {
                        self.results = []
                    } else {
                        self.search(query: value)
                    }
                })
        )
    }
    
    func search(query: String) {
        api.searchForLocationWithQuery(query: query) { (results, error) in
            guard let results = results else { return }
            DispatchQueue.main.async {
                self.results = results
            }
        }
    }
}

class WeatherDataManager: NSObject, CLLocationManagerDelegate, ObservableObject {
    
    static let shared = WeatherDataManager()
    
    var locationId: Int?
    var usingCurrentLocation: Bool = false
    private let manager = CLLocationManager()
    private let api = WillyWeatherAPI()
    private var observer: Any?

    @Published var location: WWLocation?
    @Published var simpleWeatherData: SWWeather? {
        didSet {
            print("Weather data updated")
        }
    }
    @Published var loading: Bool = false
    
    private var started: Bool = false
    
    override init() {
        super.init()
        manager.delegate = self
    }
    
    func destroy() {
        NotificationCenter.default.removeObserver(self)
        self.started = false
    }
    
    @objc func start() {
        
        #if os(watchOS)
        #else
        if !started {
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(self.start),
                name: UIApplication.willEnterForegroundNotification,
                object: nil
            )
            self.started = true
        }
        #endif
        
        self.loading = true
        if (self.usingCurrentLocation) {
            print("GETTING WEATHER FOR LOCATION")
            manager.requestWhenInUseAuthorization()
            manager.startUpdatingLocation()
        } else {
            getWeatherData(self.locationId)
        }
    }
    
    func getWeatherData(_ locationId: Int?) {
        if let lid = locationId {
            api.getWeatherForLocation(location: lid) { (weatherData, error) in
                guard let weatherData = weatherData else { return }
                DispatchQueue.main.async {
                    self.simpleWeatherData = SWWeather(weather: weatherData)
                    self.loading = false
                    print("GOT WEATHER DATA")
                    #if os(watchOS)
                    SharedSWWeatherData.shared.weatherData = self.simpleWeatherData
                    WatchComplicationHelper.shared.reloadComplications()
                    #endif
                }
            }
        }
    }
    
    func getLocationForCoords(_ coords: CLLocationCoordinate2D) {
        api.getLocationForCoords(coords: coords) { (results, error) in
            guard let results = results else { return }
            DispatchQueue.main.async {
                self.location = results
                if let loc = self.location {
                    self.getWeatherData(loc.id)
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let first = locations.first {
            if (self.usingCurrentLocation) {
                getLocationForCoords(first.coordinate)
                manager.stopUpdatingLocation()
            }
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

