//
//  WillyWeatherAPI.swift
//  Sweather 2
//
//  Created by Sam Davis on 10/6/19.
//  Copyright © 2019 Sam Davis. All rights reserved.
//

import Foundation
import CoreLocation

struct WWLocation: Codable {
    let id: Int
    let name: String
    let region: String
    let state: String
    let postcode: String
}

struct WWWeatherData: Codable {
    let location: WWLocation
    
    struct Forecasts: Codable {
        
        struct Precis: Codable {
            struct Day: Codable {
                let dateTime: String?
                struct Entry: Codable {
                    let dateTime: String?
                    let precisCode: String?
                    let precis: String?
                    let precisOverlayCode: String?
                    let night: Bool?
                }
                let entries: [Entry]
            }
            let days: [Day]
        }
        let precis: Precis
        
        struct Weather: Codable {
            struct Day: Codable {
                let dateTime: String?
                struct Entry: Codable {
                    let dateTime: String?
                    let precisCode: String?
                    let precis: String?
                    let precisOverlayCode: String?
                    let night: Bool?
                    let min: Int?
                    let max: Int?
                }
                let entries: [Entry]
            }
            let days: [Day]
        }
        let weather: Weather
        
        struct SunriseSunset: Codable {
            struct Day: Codable {
                let dateTime: String?
                struct Entry: Codable {
                    let firstLightDateTime: String?
                    let riseDateTime: String?
                    let setDateTime: String?
                    let lastLightDateTime: String?
                }
                let entries: [Entry]
            }
            let days: [Day]
        }
        let sunrisesunset: SunriseSunset
        
        struct Rainfall: Codable {
            struct Day: Codable {
                let dateTime: String?
                struct Entry: Codable {
                    let dateTime: String?
                    let startRange: Int?
                    let endRange: Int?
                    let rangeDivide: String?
                    let rangeCode: String?
                    let probability: Int?
                }
                let entries: [Entry]
            }
            let days: [Day]
        }
        let rainfall: Rainfall
    }

    let forecasts: Forecasts
    
    struct Observational: Codable {
        struct Observation: Codable {
            struct Temperature: Codable {
                let temperature: Float?
                let apparentTemperature: Float?
                let trend: Int?
            }
            let temperature: Temperature
            
            struct Humidity: Codable {
                let percentage: Int?
                let trend: Int?
            }
            let humidity: Humidity
        }
        let observations: Observation
    }
    let observational: Observational
}

struct WWLocationCoordSearchResult: Codable {
    let location: WWLocation
}

class WillyWeatherAPI {
    
    let apiURL = "https://api.willyweather.com.au/v2"
    let apiKey = "NzBhMjQ4OWU1YmE1NjBlZjhmNDU4Mj"
    
    func searchForLocationWithQuery(query: String, callback: @escaping ([WWLocation]?, Error?) -> Void) {
        guard let urlSafeQuery = query.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else { return }
        let url = "\(apiURL)/\(apiKey)/search.json?query=\(urlSafeQuery)&limit=10"
        Fetch.get(url: url) { (data, response, error) in
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
    
    func getWeatherForLocation(location: Int, callback: @escaping (WWWeatherData?, Error?) -> Void) {
        let url = "\(apiURL)/\(apiKey)/locations/\(location)/weather.json?forecasts=precis,rainfall,rainfallprobability,sunrisesunset,temperature,weather&observational=true"
        Fetch.get(url: url) { (data, response, error) in
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
    
    func getLocationForCoords(coords: CLLocationCoordinate2D, callback: @escaping (WWLocation?, Error?) -> Void) {
        let url = "\(apiURL)/\(apiKey)/search.json?lat=\(coords.latitude)&lng=\(coords.longitude)&units=distance:km"
        Fetch.get(url: url) { (data, response, error) in
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

class Fetch {
    static func get(url urlString: String, convertToString: Bool = false, callback: @escaping (Data?, URLResponse?, Error?) -> Void) {
        
        print("Fetching url: \(urlString)")

        let url = URL(string: urlString)
        let urlSession = URLSession.shared
        
        let completionHandler: (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void  = { data, response, error in
            if let error = error {
                print("Got an error!: \(error)")
            }
            callback(data, response, error)
        }
        
        let task = urlSession.dataTask(with: url!, completionHandler: completionHandler)

        task.resume()
    }
}
