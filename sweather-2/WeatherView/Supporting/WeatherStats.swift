//
//  WeatherStats.swift
//  sweather-2
//
//  Created by Sam Davis on 10/11/19.
//  Copyright © 2019 Sam Davis. All rights reserved.
//

import SwiftUI

struct WeatherStats: View {
    let weather: SWWeather
    var body: some View {
        HStack {
            WeatherStat(label: "High", value: "\(weather.temperature.max ?? 0)°")
            WeatherStat(label: "Low", value: "\(weather.temperature.min ?? 0)°")
            WeatherStat(label: "Humidity", value: "\(weather.humidity.percent ?? 0)%")
            WeatherStat(label: "Sunrise", value: "\(weather.sunrisesunset.rise?.prettyTime() ?? "-")")
            WeatherStat(label: "Sunset", value: "\(weather.sunrisesunset.set?.prettyTime() ?? "-")")
        }
    }
}

struct WeatherStat: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Spacer()
            VStack {
                Text(label).font(.footnote).padding(.bottom, 5).opacity(0.5)
                Text(value).font(.custom("", size: 16)).fixedSize()
            }
            Spacer()
        }
    }
}

struct WeatherStats_Previews: PreviewProvider {
    static var previews: some View {
        WeatherStats(weather: SampleWeatherData())
    }
}
