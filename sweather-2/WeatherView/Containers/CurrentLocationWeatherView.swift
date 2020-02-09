//
//  CurrentLocationWeatherView.swift
//  sweather-2
//
//  Created by Sam Davis on 9/11/19.
//  Copyright © 2019 Sam Davis. All rights reserved.
//

import SwiftUI

struct CurrentLocationWeatherView: View {
    @ObservedObject var manager = WeatherDataManager()
    
    init(manager: WeatherDataManager) {
        self.manager = manager
        self.manager.locationId = nil
    }
        
    var body: some View {
        VStack {
            if manager.loading == false && manager.simpleWeatherData != nil {
                WeatherViewPresentational(weather: manager.simpleWeatherData!)
            } else {
                Loading()
            }
        }.onDisappear {
            self.manager.destroy()
        }
    }
}

struct CurrentLocationWeatherView_Previews: PreviewProvider {
    static var previews: some View {
        Text("No preview for this view")
    }
}
