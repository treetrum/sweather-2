//
//  WeatherViewPresentational.swift
//  sweather-2
//
//  Created by Sam Davis on 9/11/19.
//  Copyright © 2019 Sam Davis. All rights reserved.
//

import SwiftUI

extension Int {
    func toString() -> String {
        return String(self)
    }
}

struct WeatherViewPresentational: View {
    let weather: SWWeather

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack {
                LocationName(location: weather.location)
                PrecisIcon(precisCode: weather.getPrecisImageCode())
                Text(weather.precis.precis ?? "-").padding(.bottom, 5).font(.headline).padding(.bottom, 20)
                Text("\(weather.temperature.actual?.roundToSingleDecimalString() ?? "-")°").font(.title).padding(.bottom, 5)
                if weather.temperature.apparent != nil {
                    Text("Feels like \(weather.temperature.apparent?.roundToSingleDecimalString() ?? "-")°").padding(.bottom, 15)
                }
                HighLow(weather: weather)
                RainChance(rainfall: weather.rainfall).padding(.bottom, 5)
                Text("\(weather.humidity.percent ?? 0)% humidity").padding(.bottom, 20)
                VStack {
                    Hours(weather: weather).padding(.bottom, 20)
                    Days(weather: weather).padding(.bottom)
                    Spacer()
                }
            }
        }
    }
}

struct WeatherViewPresentational_Previews: PreviewProvider {
    static var previews: some View {
        WeatherViewPresentational(weather: SampleWeatherData())
            .environmentObject(SessionData(viewingCurrentLocation: true))
    }
}
    
