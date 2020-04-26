//
//  WillyWeatherAPI.swift
//  Sweather 2
//
//  Created by Sam Davis on 10/6/19.
//  Copyright © 2019 Sam Davis. All rights reserved.
//

import Foundation
import CoreLocation

class WillyWeatherAPI {
    
    let apiURL = "https://api.willyweather.com.au/v2"
    let apiKey: String
    
    init() {
        self.apiKey = Bundle.main.object(forInfoDictionaryKey: "WillyWeatherAPIKey") as! String
    }
    
    func searchForLocationWithQuery(query: String, callback: @escaping ([WWLocation]?, Error?) -> Void) {
        guard let urlSafeQuery = query.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else { return }
        let url = "\(apiURL)/\(apiKey)/search.json?query=\(urlSafeQuery)&limit=10"
        SJDFetch.shared.get(url: url) { (data, response, error) in
            if let error = error {
                print("We got an error, aborting. \(error)")
                callback(nil, error);
            } else if let data = data {
                do {
                    let results = try JSONDecoder().decode([WWLocation].self, from: data)
                    callback(results, nil)
                } catch let error {
                    callback(nil, error);
                }
            }
        }
    }
    
    func getLocationForCoords(coords: CLLocationCoordinate2D, callback: @escaping (WWLocation?, Error?) -> Void) {
        let url = "\(apiURL)/\(apiKey)/search.json?lat=\(coords.latitude)&lng=\(coords.longitude)&units=distance:km"
        SJDFetch.shared.get(url: url) { (data, response, error) in
            if let error = error {
                print("We got an error, aborting. \(error)")
                callback(nil, error);
            } else if let data = data {
                do {
                    let result = try JSONDecoder().decode(WWLocationCoordSearchResult.self, from: data)
                    callback(result.location, nil)
                } catch let error {
                    callback(nil, error);
                }
            }
        }
    }
    
    func getWeatherForLocationURL(location: Int) -> String {
        return "\(apiURL)/\(apiKey)/locations/\(location)/weather.json?forecasts=precis,rainfall,rainfallprobability,sunrisesunset,temperature,weather&observational=true&regionPrecis=true"
    }
    
    func getWeatherForLocation(location: Int, callback: @escaping (WWWeatherData?, Error?) -> Void) {
        let url = getWeatherForLocationURL(location: location)
        SJDFetch.shared.get(url: url) { (data, response, error) in
            if let error = error {
                print("We got an error, aborting. \(error)")
                callback(nil, error);
            } else if let data = data {
                do {
                    let result = try JSONDecoder().decode(WWWeatherData.self, from: data)
                    callback(result, nil)
                } catch let error {
                    print("Got an error \(error)")
                    callback(nil, error);
                }
            }
        }
    }
    
    func getMapsForLocatoin(location: Int, callback: @escaping (WWMapData?, Error?) -> Void) {
        let url = "\(apiURL)/\(apiKey)/locations/\(location)/maps.json?mapTypes=regional-radar&offset=-60&limit=30&units=distance:km"
        SJDFetch.shared.get(url: url) { (data, response, error) in
            if let error = error {
                print("We got an error, aborting. \(error)")
                callback(nil, error);
            } else if let data = data {
                do {
                    let result = try JSONDecoder().decode([WWMapData].self, from: data)
                    if let first = result.first {
                        callback(first, nil)
                    } else {
                        callback(nil, nil)
                    }
                } catch let error {
                    print("Got an error \(error)")
                    callback(nil, error);
                }
            }
        }
    }
    
    static func getPrecisImageCode(
        forPrecisCode precisCode: String,
        and sunriseSunsetTimes: WWWeatherData.Forecasts.SunriseSunset.Day.Entry, andCurrentTime currentTime: Date = Date()) -> String {
        
        var iconCode = precisCode
        let iconsWithNightVariations = ["chance-thunderstorm-fine", "chance-shower-fine", "mostly-cloudy", "partly-cloudy", "mostly-fine", "fine"]
        
        guard let riseDateTime = self.dateTimeStringToDateTime(sunriseSunsetTimes.riseDateTime),
            let setDateTime = self.dateTimeStringToDateTime(sunriseSunsetTimes.setDateTime) else {
                return precisCode
        }
        
        // Create dates from strings
        // If it's before first light or after last light, and the icon is applicable, show a night variation of the icon.
        if iconsWithNightVariations.contains(iconCode) {
            if currentTime > setDateTime || currentTime < riseDateTime {
                iconCode += "-night"
            }
        }
        
        // Fall back to just using what was passed in
        return iconCode
    }
    
    static func dateTimeStringToDateTime(_ datetimeString: String?) -> Date? {
        
        // Create date formatter to create dates from strings
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        guard let dts = datetimeString,
            let date = dateFormatter.date(from: dts) else {
            return nil
        }
        
        return date;
        
    }
    
}
