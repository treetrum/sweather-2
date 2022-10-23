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
            Spacer()
            WeatherStat(label: "Low", value: "\(weather.temperature.min ?? 0)°")
            Spacer()
            WeatherStat(label: "Humidity", value: "\(weather.humidity.percent ?? 0)%")
            Spacer()
            WeatherStat(label: "Sunrise", value: "\(weather.sunrisesunset.rise?.prettyTime() ?? "-")")
            Spacer()
            WeatherStat(label: "Sunset", value: "\(weather.sunrisesunset.set?.prettyTime() ?? "-")")
        }.padding([.leading, .trailing])
    }
}

struct WeatherStat: View { 
    let label: String
    let value: String
    
    @Environment(\.horizontalSizeClass) var sizeClass
    var isIpad: Bool {
        get {
            if let size = sizeClass {
                return size == .regular
            } else {
                return false
            }
        }
    }
    
    var body: some View {
        HStack {
            VStack {
                Text(label)
                    .font( isIpad ? .system(size: 13) : .footnote)
                    .padding(.bottom, 5)
                    .opacity(0.5)
                Text(value)
                    .font(.system(size: isIpad ? 16 : 15))
            }
            .fixedSize()
        }.foregroundColor(Color.white)
    }
}

struct WeatherStats_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.blue
            WeatherStats(weather: SampleWeatherData.fromWW)
                .padding(.horizontal)
        }
    }
}
