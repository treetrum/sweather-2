//
//  WillyWeatherAPI.swift
//  Sweather 2
//
//  Created by Sam Davis on 10/6/19.
//  Copyright © 2019 Sam Davis. All rights reserved.
//

import Foundation

struct WWLocation: Codable {
    let id: Int
    let name: String
    let region: String
    let state: String
    let postcode: String
}

struct WWPrecisDayEntry: Codable {
    let dateTime: String
    let precisCode: String
    let precis: String
    let precisOverlayCode: String
    let night: Bool
}

struct WWPrecisDay: Codable {
    let dateTime: String
    let entries: [WWPrecisDayEntry]
}

struct WWPrecis: Codable {
    let days: [WWPrecisDay]
}

struct WWForecastWeatherDayEntry: Codable {
    let dateTime: String
    let precisCode: String
    let precis: String
    let precisOverlayCode: String
    let night: Bool
    let min: Int
    let max: Int
}

struct WWForecastWeatherDay: Codable {
    let dateTime: String
    let entries: [WWForecastWeatherDayEntry]
}

struct WWForecastWeather: Codable {
    let days: [WWForecastWeatherDay]
}

struct WWForecasts: Codable {
    let precis: WWPrecis
    let weather: WWForecastWeather
}

struct WWObservationTemperature: Codable {
    let temperature: Float
    let apparentTemperature: Float
    let trend: Int
}

struct WWObservationHumidity: Codable {
    let percentage: Int
    let trend: Int
}

struct WWObservation: Codable {
    let temperature: WWObservationTemperature
    let humidity: WWObservationHumidity
}

struct WWObservational: Codable {
    let observations: WWObservation
}

struct WWWeatherData: Codable {
    let location: WWLocation
    let forecasts: WWForecasts
    let observational: WWObservational
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
