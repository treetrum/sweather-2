//
//  WWDataManagers.swift
//  sweather-2
//
//  Created by Sam Davis on 29/10/19.
//  Copyright © 2019 Sam Davis. All rights reserved.
//

import Foundation
import CoreLocation

class SearchDataManger: ObservableObject {

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
    let api = WillyWeatherAPI()
    
    @Published var weatherData: WWWeatherData?
    
    init(locationId: Int) {
        getWeatherData(locationId: locationId)
    }
    
    func getWeatherData(locationId: Int) {
        api.getWeatherForLocation(location: locationId) { (weatherData, error) in
            guard let weatherData = weatherData else { return }
            DispatchQueue.main.async {
                self.weatherData = weatherData
            }
        }
    }
}


class LocationWeatherDataManager: ObservableObject {
    
    let api = WillyWeatherAPI()
    
    @Published var location: WWLocation?
    
    func getLocationForCoords(_ coords: CLLocationCoordinate2D) {
        api.getLocationForCoords(coords: coords) { (results, error) in
            guard let results = results else { return }
            DispatchQueue.main.async {
                self.location = results
                print("Got results \(results)")
            }
        }
    }
}
