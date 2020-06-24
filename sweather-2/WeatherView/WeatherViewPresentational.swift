
//  WeatherViewPresentational.swift
//  sweather-2
//
//  Created by Sam Davis on 9/11/19.
//  Copyright © 2019 Sam Davis. All rights reserved.
//

import SwiftUI
import GoogleMobileAds

extension Int {
    func toString() -> String {
        return String(self)
    }
}

struct WeatherViewPresentational: View {
    
    @State var showRadar = false
    @ObservedObject var sessionData = SessionData.shared
    @EnvironmentObject var appState: AppState
    let weather: SWWeather

    var body: some View {
        GeometryReader { (geometry: GeometryProxy) in
            ScrollView(.vertical, showsIndicators: false) {
                // Above the fold
                Spacer().frame(height: geometry.safeAreaInsets.top)
                VStack {
                    AdBanner()
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
                    WeatherStats(weather: self.weather)
                        .padding([.top])
                        .padding(.bottom, 25)
                }
                .frame(height: geometry.size.height - geometry.safeAreaInsets.top)
                
                // Below the fold
                Days(weather: self.weather).padding(.bottom, 25)
                Button(action: {
                    self.appState.showSheet(.rainRadar)
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
                }
            }
            .foregroundColor(Color.white)
        }
        .offset(x: 0, y: 8)
        .edgesIgnoringSafeArea(.all)
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
            BackgroundGradient()
            WeatherViewPresentational(weather: SampleWeatherData())
                .environmentObject(SessionData(viewingCurrentLocation: true))
        }
    }
}

