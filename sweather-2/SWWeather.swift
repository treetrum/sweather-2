//
//  SWWeather.swift
//  sweather-2
//
//  Created by Sam Davis on 29/10/19.
//  Copyright © 2019 Sam Davis. All rights reserved.
//

import Foundation

struct SWWeather {
    
    let location: WWLocation
    
    struct Precis {
        let precis: String?
        let precisCode: String?
    }
    var precis = Precis(precis: nil, precisCode: nil)
    
    struct Temperature {
        let max: Int?
        let min: Int?
        let apparent: Float?
        let actual: Float?
    }
    var temperature = Temperature(max: nil, min: nil, apparent: nil, actual: nil)
    
    struct Rainfall {
        let startRange: Int?
        let endRange: Int?
        let rangeDivide: String?
        let rangeCode: String?
        let probability: Int?
    }
    var rainfall = Rainfall(startRange: nil, endRange: nil, rangeDivide: nil, rangeCode: nil, probability: nil)
    
    struct SunriseSunset {
        let rise: Date?
        let set: Date?
        let firstLight: Date?
        let lastLight: Date?
    }
    var sunrisesunset = SunriseSunset(rise: nil, set: nil, firstLight: nil, lastLight: nil)
    
    struct Humidity {
        let percent: Int?
    }
    var humidity = Humidity(percent: nil)
    
    init(weather: WWWeatherData) {
        
        self.location = weather.location
        
        if let weatherDay = weather.forecasts.weather.days.first,
            let weatherDayEntry = weatherDay.entries.first {
            
            self.precis = SWWeather.Precis(
                precis: weatherDayEntry.precis,
                precisCode: weatherDayEntry.precisCode
            )
        
            self.temperature = SWWeather.Temperature(
                max: weatherDayEntry.max,
                min: weatherDayEntry.min,
                apparent: weather.observational.observations.temperature.apparentTemperature,
                actual: weather.observational.observations.temperature.temperature
            )

        }
        
        if let rainfallDay = weather.forecasts.rainfall.days.first,
            let rainfallDayEntry = rainfallDay.entries.first {
            
            self.rainfall = Rainfall(
                startRange: rainfallDayEntry.startRange,
                endRange: rainfallDayEntry.endRange,
                rangeDivide: rainfallDayEntry.rangeDivide,
                rangeCode: rainfallDayEntry.rangeCode,
                probability: rainfallDayEntry.probability
            )
        }
        
        if let ssDay = weather.forecasts.sunrisesunset.days.first,
            let ssDayEntry = ssDay.entries.first {
            
            self.sunrisesunset = SunriseSunset(
                rise: WillyWeatherAPI.dateTimeStringToDateTime(ssDayEntry.riseDateTime),
                set: WillyWeatherAPI.dateTimeStringToDateTime(ssDayEntry.setDateTime),
                firstLight: WillyWeatherAPI.dateTimeStringToDateTime(ssDayEntry.firstLightDateTime),
                lastLight: WillyWeatherAPI.dateTimeStringToDateTime(ssDayEntry.lastLightDateTime)
            )
        }
        
        self.humidity = Humidity(
            percent: weather.observational.observations.humidity.percentage
        )
        
    }

}
