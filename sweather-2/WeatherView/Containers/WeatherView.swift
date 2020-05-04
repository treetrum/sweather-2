//
//  WeatherView.swift
//  sweather-2
//
//  Created by Sam Davis on 9/11/19.
//  Copyright © 2019 Sam Davis. All rights reserved.
//

import SwiftUI

struct WeatherView: View {
    
    @ObservedObject var manager: WeatherDataManager
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    init(location: WWLocation) {
        self.manager = WeatherDataManager.shared
        self.manager.usingCurrentLocation = false
        if self.manager.locationId != location.id {
            self.manager.locationId = location.id
            self.manager.start()
        }
    }

    var body: some View {
        VStack {
            if manager.loading == false && manager.simpleWeatherData != nil {
                WeatherViewPresentational(weather: manager.simpleWeatherData!)
            } else if manager.loading {
                Loading()
            } else {
                Text("Not loading")
            }
        }
    }
}

struct WeatherView_Previews: PreviewProvider {
    static var previews: some View {
        Text("no preview for this view")
    }
}
