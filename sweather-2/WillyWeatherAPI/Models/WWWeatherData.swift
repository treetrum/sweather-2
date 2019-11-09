//
//  WWWeatherData.swift
//  sweather-2
//
//  Created by Sam Davis on 10/11/19.
//  Copyright © 2019 Sam Davis. All rights reserved.
//

import Foundation

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
