
//  WeatherViewPresentational.swift
//  sweather-2
//
//  Created by Sam Davis on 9/11/19.
//  Copyright © 2019 Sam Davis. All rights reserved.
//

import SwiftUI
import WeatherKit

extension Int {
    func toString() -> String {
        return String(self)
    }
}

struct WeatherViewPresentational: View {
    
    @State var showRadar = false
    @ObservedObject var sessionData = SessionData.shared
    @EnvironmentObject var appState: AppState 
    @Environment(\.horizontalSizeClass) var sizeClass
    @Environment(\.colorScheme) var colorScheme
    let weather: SWWeather
    
    @State var attribution: WeatherAttribution?
    
    var mainInformation: some View {
        VStack {
            if self.weather.isWeatherkit {
                PrecisIconWeatherkit(symbolName: self.weather.precis.precisCode ?? "")
            } else {
                PrecisIcon(precisCode: self.weather.getPrecisImageCode()).padding(.bottom, -20)
            }
            Precis(weather: self.weather)
            RainChance(rainfall: self.weather.rainfall, isWeatherkit: weather.isWeatherkit)
                .foregroundColor(Color.white)
                .opacity(0.5)
                .padding(.bottom, 40)
            Temperatures(weather: self.weather)
        }
    }
    
    var iPhoneLayout: some View {
        GeometryReader { (geometry: GeometryProxy) in
            ScrollView(.vertical, showsIndicators: false) {
                // Above the fold
                VStack {
                    Spacer().frame(height: geometry.safeAreaInsets.top)
                    Spacer().frame(height: 40)
                    LocationName(location: self.weather.location)
                    Spacer()
                    mainInformation
                    Spacer()
                    Hours(weather: self.weather, isWeatherKit: weather.isWeatherkit)
                    WeatherStats(weather: self.weather)
                        .padding([.top])
                        .padding(.bottom, 25)
                }
                .frame(height: geometry.size.height - geometry.safeAreaInsets.top)
                
                // Below the fold
                Days(weather: self.weather).padding(.bottom, 25)
                RainRadarButton()
                
                //
                HStack {
                    
                    if let assetUrl = attribution?.combinedMarkDarkURL {
                        AsyncImage(url: assetUrl, scale: 3) { res in
                            res.image?
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        }
                        .padding(2)
                        .frame(height: 18)
                    }
                    
                    Spacer()
                    
                    if let legalUrl = attribution?.legalPageURL.absoluteString {
                        Text(.init("[Legal](\(legalUrl))"))
                            .multilineTextAlignment(.trailing)
                            .tint(.white)
                            .font(.system(size: 14))
                            .underline()
                    }
                }
                .padding([.leading, .trailing])
                .padding([.top, .bottom], 25)
            }
        }
        .offset(x: 0, y: 8)
        .edgesIgnoringSafeArea(.all)
        .task {
            Task {
                if attribution == nil {
                    let weatherService = WeatherService()
                    let attribution = try! await weatherService.attribution
                    self.attribution = attribution
                }
            }
        }
    }
    
    var iPadLayout: some View {
        GeometryReader { (geometry: GeometryProxy) in
            VStack {
                HStack {
                    
                    // Main column
                    VStack {
                        VStack {
                            LocationName(location: self.weather.location)
                            Spacer()
                            mainInformation
                            Spacer()
                            Hours(weather: self.weather, isWeatherKit: weather.isWeatherkit)
                        }
                        WeatherStats(weather: self.weather)
                            .padding([.top])
                            .padding(.bottom, 25)
                    }

                    // Separator
                    VStack {
                        EmptyView()
                    }
                    .frame(minWidth: 1, maxWidth: 1, minHeight: 0, maxHeight: .infinity)
                    .background(Color.white.opacity(0.5))
                    .padding(.all, 20)
                    
                    // Right hand column
                    VStack {
                        Days(weather: self.weather)
                        Spacer()
                        RainRadarButton()
                    }
                    .frame(
                        minWidth: 0,
                        maxWidth: geometry.size.width * (geometry.size.width > geometry.size.height ? 0.25 :  0.3)
                    )

                }
            }
        }
    }

    var body: some View {
        Group {
            if isIpad(sizeClass) {
                iPadLayout
            } else {
                iPhoneLayout
            }
        }.foregroundColor(Color.white)
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
            WeatherViewPresentational(weather: SampleWeatherData.fromWW)
                .environmentObject(SessionData(viewingCurrentLocation: true))
        }.edgesIgnoringSafeArea(.all)
        
    }
}

