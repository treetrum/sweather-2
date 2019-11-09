//
//  RainChance.swift
//  sweather-2
//
//  Created by Sam Davis on 9/11/19.
//  Copyright © 2019 Sam Davis. All rights reserved.
//

import SwiftUI

struct RainChance: View {
    let rainfall: SWWeather.Rainfall

    var body: some View {
        VStack {
            if rainfall.probability ?? 0 > 0 {
                Text("\(rainfall.probability ?? 0)% chance of \(rainfall.startRange != nil ? "\(rainfall.startRange!)" : "")\(rainfall.rangeDivide ?? "")\(rainfall.endRange ?? 0)mm")
            } else {
                Text("No rainfall forecast")
            }
        }
    }
}

struct RainChance_Previews: PreviewProvider {
    static var previews: some View {
        RainChance(rainfall: SampleWeatherData().rainfall)
    }
}
