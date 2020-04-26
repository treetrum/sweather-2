
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
    @State var showRadar = false
    let weather: SWWeather
    var body: some View {
        GeometryReader { geometry in
            ScrollView(.vertical, showsIndicators: false) {
                VStack {
                    LocationName(location: self.weather.location)
                    Spacer()
                    PrecisIcon(precisCode: self.weather.getPrecisImageCode()).padding(.bottom, -20)
                    Precis(weather: self.weather)
                    RainChance(rainfall: self.weather.rainfall)
                        .foregroundColor(Color.white)
                        .opacity(0.5)
                        .padding(.bottom, 40)
                    Temperatures(weather: self.weather)
                    Spacer()
                    Hours(weather: self.weather)
                    WeatherStats(weather: self.weather).padding([.top]).padding(.bottom, 25)
                }.frame(height: geometry.size.height)
                Days(weather: self.weather).padding(.bottom, 25)
                Button(action: {
                    self.showRadar = true
                }) {
                    Text("Rain Radar")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .overlay(
                             RoundedRectangle(cornerRadius: 4)
                                 .stroke(Color.white, lineWidth: 1)
                         )
                        .padding(.horizontal)
                        .padding(.bottom, 25)
                }.sheet(isPresented: self.$showRadar) {
                    NavigationView {
                        RainRadar(locationId: self.weather.location.id)
                            .navigationBarTitle(Text("Rain Radar"), displayMode: .inline)
                            .navigationBarItems(
                                leading: Button(action: {
                                    self.showRadar = false
                                }) {
                                    Text("Done")
                                }
                            )
                    }
                }
            }.foregroundColor(Color.white)
        }
    }
}

struct Precis: View {
    var weather: SWWeather
    var body: some View {
        Text(self.weather.precis.precis ?? "-").font(.headline).padding(.bottom, 5)
    }
}

struct Temperatures: View {
    var weather: SWWeather
    var body: some View {
        VStack {
            Text("\(self.weather.temperature.actual?.roundToSingleDecimalString() ?? "-")°")
                .font(.system(size: 36))
                .fontWeight(.bold)
            if self.weather.temperature.apparent != nil {
                Text("Feels like \(self.weather.temperature.apparent?.roundToSingleDecimalString() ?? "-")°")
                    .font(.system(size: 20))
                    .fontWeight(.medium)
                    .opacity(0.5)
                    .padding(.top, 5)
            }
        }
    }
}

struct WeatherViewPresentational_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            BackgroundGradient(manager: WeatherDataManager())
            WeatherViewPresentational(weather: SampleWeatherData())
                .environmentObject(SessionData(viewingCurrentLocation: true))
        }
    }
}
    
