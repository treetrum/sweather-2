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
        GeometryReader { geometry in
            ScrollView(.vertical, showsIndicators: false) {
                VStack {
                    LocationName(location: self.weather.location).padding(.top, 30)
                    Spacer()
                    PrecisIcon(precisCode: self.weather.getPrecisImageCode())
                    Text(self.weather.precis.precis ?? "-").font(.headline).padding(.bottom, 5)
                    RainChance(rainfall: self.weather.rainfall).padding(.bottom, 40).opacity(0.5)
                    Text("\(self.weather.temperature.actual?.roundToSingleDecimalString() ?? "-")°").font(.title)
                    if self.weather.temperature.apparent != nil {
                        Text("Feels like \(self.weather.temperature.apparent?.roundToSingleDecimalString() ?? "-")°").opacity(0.5).padding(.top, 5)
                    }
                    Spacer()
                    WeatherStats(weather: self.weather).padding(.bottom, 40).padding(.top, 40)
                }.frame(height: geometry.size.height)
                VStack {
                    Hours(weather: self.weather).padding(.bottom, 40)
                    Days(weather: self.weather).padding(.bottom, 40)
                }.padding(.top, 22)
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
    
