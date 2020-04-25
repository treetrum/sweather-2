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
        let date: Date?
    }
    var temperature = Temperature(max: nil, min: nil, apparent: nil, actual: nil, date: nil)
    
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
    
    struct Hour {
        let dateTime: Date?
        let temperature: Float?
        let precis: String?
        let precisCode: String?
        let night: Bool?
    }
    var hours = [Hour]()
    
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
                actual: weather.observational.observations.temperature.temperature,
                date: WillyWeatherAPI.dateTimeStringToDateTime(weather.observational.issueDateTime)
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
        
        let maxNumberOfHours = 24
        var hours = [Hour]()
        var lastUsedPrecis: String? = ""
        var lastUsedPrecisCode: String? = ""
        var lastUsedIsNight: Bool? = false
        weather.forecasts.temperature.days.forEach { day in
            day.entries.forEach { (day) in

                if let date = WillyWeatherAPI.dateTimeStringToDateTime(day.dateTime) {
                    // If the current time is the same hour or less than the candidate date
                    if Calendar.current.isDate(Date(), equalTo: date, toGranularity: .hour) || Date() < date {
                        
                        weather.forecasts.precis.days.forEach { (precisDay) in
                            precisDay.entries.forEach { (precisEntry) in
                                if let precisDate = WillyWeatherAPI.dateTimeStringToDateTime(precisEntry.dateTime) {
                                    
                                    /// Because precis data is only provided in 3hour intervals, there is a chance that the first
                                    /// readout is before our first temperature entry. To combat this, we add three hours to the
                                    /// current date and if it's after the current time, we use that precis data for the initial entry
                                    let threeHoursInSeconds: Double = 60.0 * 60.0 * 3.0
                                    let threeHoursAfter = precisDate.addingTimeInterval(threeHoursInSeconds)
                                    if Date() < threeHoursAfter && lastUsedPrecis == "" {
                                        lastUsedPrecis = precisEntry.precis
                                        lastUsedPrecisCode = precisEntry.precisCode
                                        lastUsedIsNight = precisEntry.night
                                    }

                                    if Calendar.current.isDate(precisDate, equalTo: date, toGranularity: .hour) {
                                        lastUsedPrecis = precisEntry.precis
                                        lastUsedPrecisCode = precisEntry.precisCode
                                        lastUsedIsNight = precisEntry.night
                                    }
                                }
                            }
                        }
                        
                        let hour = Hour(
                            dateTime: date,
                            temperature: day.temperature,
                            precis: lastUsedPrecis,
                            precisCode: lastUsedPrecisCode,
                            night: lastUsedIsNight
                        )
                        hours.append(hour)
                    }
                }
            }
        }
        self.hours = hours.count > maxNumberOfHours
            ? Array(hours[0...maxNumberOfHours])
            : hours
    }
    
    static let iconsWithNightVariations = ["chance-thunderstorm-fine", "chance-shower-fine", "mostly-cloudy", "partly-cloudy", "mostly-fine", "fine"]
    
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
    
    enum SWTimePeriod: Int {
        case sunriseOccuring = 0
        case postSunrise = 1
        case preSunset = 2
        case sunsetOccurring =  3
        case isDayTime = 4
        case isNightTime = 5
    }
    
    private func secsToMins(_ seconds: Double) -> Double { return seconds * 60.0 }
    
    func getTimePeriod() -> SWTimePeriod {
                
        guard let dateToCheck = self.temperature.date,
            let riseDateTime = self.sunrisesunset.rise,
            let setDateTime = self.sunrisesunset.set else {
            return .isDayTime
        }
        
        let halfHourBeforeSunrise = riseDateTime.addingTimeInterval(secsToMins(-30))
        let halfHourAfterSunrise = riseDateTime.addingTimeInterval(secsToMins(30))
        let hourAndHalfAfterSunrise = riseDateTime.addingTimeInterval(secsToMins(90))
        let hourAndHalfBeforeSunset = setDateTime.addingTimeInterval(secsToMins(-90))
        let halfHourBeforeSunset = setDateTime.addingTimeInterval(secsToMins(-30))
        let halfHourAfterSunset = setDateTime.addingTimeInterval(secsToMins(30))
        
        let sunriseOccurring = (halfHourBeforeSunrise...halfHourAfterSunrise).contains(dateToCheck)
        if (sunriseOccurring) {
            return .sunriseOccuring
        }
        
        let postSunrise = (halfHourAfterSunrise...hourAndHalfAfterSunrise).contains(dateToCheck)
        if (postSunrise) {
            return .postSunrise
        }
        
        let preSunset = (hourAndHalfBeforeSunset...halfHourBeforeSunset).contains(dateToCheck)
        if (preSunset) {
            return .preSunset
        }
        
        let sunsetOccurring = (halfHourBeforeSunset...halfHourAfterSunset).contains(dateToCheck)
        if (sunsetOccurring) {
            return .sunsetOccurring
        }
        
        let isDayTime = (riseDateTime...setDateTime).contains(dateToCheck)
        if (isDayTime) {
            return .isDayTime
        }
        
        return .isNightTime
    }
    
    static func getPrecisImageCode(
        forPrecisCode precisCode: String,
        andSunriseSunset sunriseSunset: SWWeather.SunriseSunset,
        andCurrentTime iconTime: Date = Date()
    ) -> String {
        
        var iconCode = precisCode
        
        guard let sunriseDateTime = sunriseSunset.rise,
            let sunsetDateTime = sunriseSunset.set else {
                return precisCode
        }
        
        // Create dates from strings
        // If it's before first light or after last light, and the icon is applicable, show a night variation of the icon.
        if SWWeather.iconsWithNightVariations.contains(iconCode) {
            if iconTime > sunsetDateTime || iconTime < sunriseDateTime {
                iconCode += "-night"
            }
        }
        
        // Fall back to just using what was passed in
        return iconCode
    }
    
    static func getPrecisImageCode(forPrecisCode precisCode: String?, andIsNight isNight: Bool?) -> String {
        var iconCode = precisCode != nil && precisCode != "" ? precisCode! : "fine"
        if SWWeather.iconsWithNightVariations.contains(iconCode) && isNight == true {
            iconCode += "-night"
        }
        return iconCode
    }

}

