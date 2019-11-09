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

func readWWWeatherJSON(path: String) -> WWWeatherData? {
    let url = Bundle.main.url(forResource: path, withExtension: "json")
    if let jsonURL = url {
        do {
            let data = try Data(contentsOf: jsonURL)
            let decoder = JSONDecoder()
            let jsonData = try decoder.decode(WWWeatherData.self, from: data)
            return jsonData
        } catch {
            return nil
        }
    }
    return nil
}


struct WeatherViewPresentational: View {
    let weather: SWWeather
    var isCurrentLocation: Bool = false
    
    @Environment(\.colorScheme) var colorScheme: ColorScheme

    var body: some View {
        VStack {
            HStack {
                Spacer()
                if isCurrentLocation {
                    Image(systemName: "location.fill")
                }
                Text(weather.location.name).font(.headline)
                Spacer()
            }
            if colorScheme == .dark {
                Image(weather.getPrecisImageCode())
            } else {
                Image(weather.getPrecisImageCode()).colorInvert()
            }
            Text(weather.precis.precis ?? "-")
            Spacer().frame(height: 10)
            Text("\(weather.temperature.actual?.roundToSingleDecimalString() ?? "-")°")
            Spacer().frame(height: 10)
            if weather.temperature.apparent != nil {
                Text("Feels like \(weather.temperature.apparent?.roundToSingleDecimalString() ?? "-")°")
                Spacer().frame(height: 10)
            }
            HStack {
                Image(systemName: "arrow.up")
                Text("\(weather.temperature.max?.toString() ?? "-")")
                Spacer().frame(width: 20)
                Image(systemName: "arrow.down")
                Text("\(weather.temperature.min?.toString() ?? "-")")
            }
            Spacer()
        }
    }
}

struct WeatherViewPresentational_Previews: PreviewProvider {
    static var previews: some View {
        WeatherViewPresentational(
            weather: SWWeather(weather: readWWWeatherJSON(path: "sample-weather-data")!),
            isCurrentLocation: true
        )
    }
}
