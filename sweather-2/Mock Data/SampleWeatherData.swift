//
//  SampleWeatherData.swift
//  sweather-2
//
//  Created by Sam Davis on 9/11/19.
//  Copyright © 2019 Sam Davis. All rights reserved.
//

import Foundation

struct SampleWeatherData {
    
    static var fromWW: SWWeather {
        var weather = fromWeatherkit
        weather.precis.precisCode = "mostly-cloudy"
        weather.days = weather.days.map({ d in
            var newDay = d
            newDay.precisCode = "mostly-cloudy"
            return newDay
        })
        weather.hours = weather.hours.map({ d in
            var newHour = d
            newHour.precisCode = "mostly-cloudy"
            return newHour
        })
        weather.isWeatherkit = false
        return weather
    }
        
    static var fromWeatherkit: SWWeather {
        return SWWeather(
            location: WWLocation(id: 1, name: "Sydney", region: "Sydney", state: "NSW", postcode: "2000"),
            precis: .init(precis: "Stormy", precisCode: "cloud.sun.bolt"),
            temperature: .init(max: 30, min: 15, apparent: 16, actual: 17, date: Date()),
            days: [
                .init(dateTime: Date(), precisCode: "cloud.sun.bolt", precis: "Stormy", precisOverlayCode: nil, night: nil, min: 18, max: 30),
                .init(dateTime: Date().addingTimeInterval(86400 * 1), precisCode: "sun.max", precis: "Stormy", precisOverlayCode: nil, night: nil, min: 18, max: 30),
                .init(dateTime: Date().addingTimeInterval(86400 * 2), precisCode: "sun.haze", precis: "Stormy", precisOverlayCode: nil, night: nil, min: 18, max: 30),
                .init(dateTime: Date().addingTimeInterval(86400 * 3), precisCode: "cloud.heavyrain", precis: "Stormy", precisOverlayCode: nil, night: nil, min: 18, max: 30),
                .init(dateTime: Date().addingTimeInterval(86400 * 4), precisCode: "tornado", precis: "Stormy", precisOverlayCode: nil, night: nil, min: 18, max: 30),
                .init(dateTime: Date().addingTimeInterval(86400 * 5), precisCode: "snowflake", precis: "Stormy", precisOverlayCode: nil, night: nil, min: 18, max: 30),
                .init(dateTime: Date().addingTimeInterval(86400 * 6), precisCode: "cloud.sun.bolt", precis: "Stormy", precisOverlayCode: nil, night: nil, min: 18, max: 30),
            ],
            hours: [
                .init(dateTime: Date(), temperature: 24, precis: nil, precisCode: "cloud.sun.bolt", night: nil),
                .init(dateTime: Date().addingTimeInterval(3600 * 1), temperature: 24, precis: nil, precisCode: "sun.max", night: nil),
                .init(dateTime: Date().addingTimeInterval(3600 * 2), temperature: 23, precis: nil, precisCode: "sun.haze", night: nil),
                .init(dateTime: Date().addingTimeInterval(3600 * 3), temperature: 22, precis: nil, precisCode: "cloud.heavyrain", night: nil),
                .init(dateTime: Date().addingTimeInterval(3600 * 4), temperature: 21, precis: nil, precisCode: "tornado", night: nil),
                .init(dateTime: Date().addingTimeInterval(3600 * 5), temperature: 26, precis: nil, precisCode: "snowflake", night: nil),
                .init(dateTime: Date().addingTimeInterval(3600 * 6), temperature: 28, precis: nil, precisCode: "cloud.sun.bolt", night: nil),
                .init(dateTime: Date().addingTimeInterval(3600 * 7), temperature: 28, precis: nil, precisCode: "sun.max", night: nil),
            ],
            isWeatherkit: true
        )
    }
}
