//
//  WatchContentView.swift
//  sweather-watch Extension
//
//  Created by Sam Davis on 9/2/20.
//  Copyright © 2020 Sam Davis. All rights reserved.
//

import SwiftUI
import WatchKit

struct WatchContentView: View {
    
    @ObservedObject var manager: WeatherDataManager = WeatherDataManager.shared
    
    init() {
        WatchComplicationHelper.shared.reloadComplications()
    }

    var body: some View {
        VStack {
            if (manager.simpleWeatherData != nil) {
                WatchWeatherView(weather: manager.simpleWeatherData!, loading: manager.loading)
            } else if (manager.loading == true) {
                Text("Loading...")
            } else if (manager.simpleWeatherData == nil) {
                Text("No weather data to show")
            }
        }.onReceive(NotificationCenter.default.publisher(for: Notification.Name("watch-app-opened"))) { _ in
            self.manager.getLocation()
        }
    }
}

struct WatchContentView_Previews: PreviewProvider {
    static var previews: some View {
        WatchContentView()
    }
}
