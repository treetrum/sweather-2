//
//  WatchWeatherView.swift
//  sweather-watch Extension
//
//  Created by Sam Davis on 9/2/20.
//  Copyright © 2020 Sam Davis. All rights reserved.
//

import SwiftUI

struct WatchWeatherView: View {
    let weather: SWWeather
    let loading: Bool
    var body: some View {
        VStack(alignment: .center) {
            if loading {
                Text("Loading").padding(.bottom, 10).font(.footnote)
            }
            Text("\(weather.location.name)").padding(.bottom, 10).font(.headline)
            Text("\(weather.temperature.actual?.roundToSingleDecimalString() ?? "-")°C").font(.title)
            Text(weather.precis.precis ?? "").padding(.top, 10).font(.footnote)
        }.multilineTextAlignment(.center)
    }
}

struct WatchWeatherView_Previews: PreviewProvider {
    static var previews: some View {
        WatchWeatherView(weather: SampleWeatherData(), loading: true)
    }
}
