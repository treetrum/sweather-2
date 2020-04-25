//
//  WeatherView.swift
//  sweather-2
//
//  Created by Sam Davis on 9/11/19.
//  Copyright © 2019 Sam Davis. All rights reserved.
//

import SwiftUI

struct WeatherView: View {
    
    @ObservedObject var weatherDataManager: WeatherDataManager
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    init(location: WWLocation, manager: WeatherDataManager) {
        self.weatherDataManager = manager
        self.weatherDataManager.usingCurrentLocation = false
        self.weatherDataManager.locationId = location.id
    }
    
    var body: some View {
        VStack {
            if weatherDataManager.loading == false && weatherDataManager.simpleWeatherData != nil {
                WeatherViewPresentational(weather: weatherDataManager.simpleWeatherData!)
            } else {
                Loading()
            }
        }
    }
}

struct WeatherView_Previews: PreviewProvider {
    static var previews: some View {
        Text("no preview for this view")
    }
}
