//
//  CurrentLocationWeatherView.swift
//  sweather-2
//
//  Created by Sam Davis on 9/11/19.
//  Copyright © 2019 Sam Davis. All rights reserved.
//

import SwiftUI

struct CurrentLocationWeatherView: View {
    @ObservedObject var manager: WeatherDataManager
    
    init() {
        self.manager = WeatherDataManager.shared
        if self.manager.usingCurrentLocation != true {
            self.manager.usingCurrentLocation = true
            self.manager.locationId = nil
            self.manager.start()
        }
    }
        
    var body: some View {
        VStack {
            if manager.loading == false && manager.simpleWeatherData != nil {
                WeatherViewPresentational(weather: manager.simpleWeatherData!)
            } else if manager.loading == true {
                Loading()
            } else {
                VStack {
                    Spacer()
                    Text("Not loading")
                    Spacer()
                }
                .foregroundColor(.white)
                .padding()
                .multilineTextAlignment(.center)
            }
        }
    }
}

struct CurrentLocationWeatherView_Previews: PreviewProvider {
    static var previews: some View {
        Text("No preview for this view")
    }
}
