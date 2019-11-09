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

func decodeLocalJSON<T: Codable>(_ path: String, type: T.Type) -> T? {
    let url = Bundle.main.url(forResource: path, withExtension: "json")
    if let jsonURL = url {
        do {
            let data = try Data(contentsOf: jsonURL)
            let decoder = JSONDecoder()
            let jsonData = try decoder.decode(T.self, from: data)
            return jsonData
        } catch {
            return nil
        }
    }
    return nil
}


struct WeatherViewPresentational: View {
    let weather: SWWeather

    var body: some View {
        VStack {
            LocationName(location: weather.location)
            PrecisIcon(precisCode: weather.getPrecisImageCode())
            Text(weather.precis.precis ?? "-").padding(.bottom, 5).font(.headline).padding(.bottom, 20)
            Text("\(weather.temperature.actual?.roundToSingleDecimalString() ?? "-")°").font(.title).padding(.bottom, 5)
            if weather.temperature.apparent != nil {
                Text("Feels like \(weather.temperature.apparent?.roundToSingleDecimalString() ?? "-")°").padding(.bottom, 30)
            }
            HighLow(weather: weather)
            RainChance(rainfall: weather.rainfall).padding(.bottom, 5)
            Text("\(weather.humidity.percent ?? 0)% humidity").padding(.bottom, 5)
            Spacer()
        }
    }
}

struct WeatherViewPresentational_Previews: PreviewProvider {
    static var previews: some View {
        WeatherViewPresentational(
            weather: SWWeather(weather: decodeLocalJSON("sample-weather-data", type: WWWeatherData.self)!)
        ).environmentObject(SessionData(viewingCurrentLocation: true))
    }
}
