//
//  SWWeather.swift
//  sweather-2
//
//  Created by Sam Davis on 29/10/19.
//  Copyright © 2019 Sam Davis. All rights reserved.
//

import Foundation

class SWWeather {
    
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
    
    struct Day {
        let dateTime: Date?
        let precisCode: String?
        let precis: String?
        let precisOverlayCode: String?
        let night: Bool?
        let min: Int?
        let max: Int?
    }
    var days = [Day]()
    
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
        
        weather.forecasts.weather.days.forEach { weatherDay in
            if let entry = weatherDay.entries.first {
                let day = SWWeather.Day(
                    dateTime: WillyWeatherAPI.dateTimeStringToDateTime(entry.dateTime),
                    precisCode: entry.precisCode,
                    precis: entry.precis,
                    precisOverlayCode: entry.precisOverlayCode,
                    night: entry.night,
                    min: entry.min,
                    max: entry.max
                )
                self.days.append(day)
            }
        }
        
    }
    
    func getPrecisImageCode() -> String {
        
        var iconCode = self.precis.precisCode ?? "fine"
        
        let iconsWithNightVariations = ["chance-thunderstorm-fine", "chance-shower-fine", "mostly-cloudy", "partly-cloudy", "mostly-fine", "fine"]
        let currentTime: Date = Date()
        
        guard let rise = self.sunrisesunset.rise,
            let set = self.sunrisesunset.set else {
                return iconCode
        }
        
        if (iconsWithNightVariations.contains(iconCode)) {
            if currentTime > set || currentTime < rise {
                iconCode += "-night"
            }
        }
        
        return iconCode
    }
    
    static func getPrecisImageCode(
        forPrecisCode precisCode: String,
        andSunriseSunset sunriseSunset: SWWeather.SunriseSunset,
        andCurrentTime currentTime: Date = Date()
    ) -> String {
        
        var iconCode = precisCode
        let iconsWithNightVariations = ["chance-thunderstorm-fine", "chance-shower-fine", "mostly-cloudy", "partly-cloudy", "mostly-fine", "fine"]
        
        guard let riseDateTime = sunriseSunset.rise,
            let setDateTime = sunriseSunset.set else {
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

}

extension Date {
    func prettyDayName() -> String {
        if (Calendar.current.isDateInToday(self)) {
            return "Today"
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: self)
    }
}
