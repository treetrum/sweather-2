//
//  HighLow.swift
//  sweather-2
//
//  Created by Sam Davis on 9/11/19.
//  Copyright © 2019 Sam Davis. All rights reserved.
//

import SwiftUI

struct HighLow: View {
    
    let weather: SWWeather

    var body: some View {
        HStack {
            Image(systemName: "arrow.up")
            Text("\(weather.temperature.max?.toString() ?? "-")")
            Spacer().frame(width: 20)
            Image(systemName: "arrow.down")
            Text("\(weather.temperature.min?.toString() ?? "-")")
        }.foregroundColor(Color.white)
    }
}

struct HighLow_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.blue
            HighLow(weather: SampleWeatherData.fromWW)
        }
    }
}
