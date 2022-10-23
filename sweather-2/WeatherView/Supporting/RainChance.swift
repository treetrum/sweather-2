//
//  RainChance.swift
//  sweather-2
//
//  Created by Sam Davis on 9/11/19.
//  Copyright © 2019 Sam Davis. All rights reserved.
//

import SwiftUI

struct RainChance: View {
    
    @EnvironmentObject var appState: AppState
    
    let rainfall: SWWeather.Rainfall
    let isWeatherkit: Bool

    var body: some View {
        Button(action: handleClick) {
            Text(rainfall.getProbabilityString(isWeatherkit: isWeatherkit))
        }.foregroundColor(.white)
    }
    
    func handleClick() {
        appState.showSheet(.rainRadar)
    }
}

struct RainChance_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.blue
            RainChance(rainfall: SampleWeatherData.fromWW.rainfall, isWeatherkit: true)
        }
    }
}
