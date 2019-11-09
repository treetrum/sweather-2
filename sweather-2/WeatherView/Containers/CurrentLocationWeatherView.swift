//
//  CurrentLocationWeatherView.swift
//  sweather-2
//
//  Created by Sam Davis on 9/11/19.
//  Copyright © 2019 Sam Davis. All rights reserved.
//

import SwiftUI

struct CurrentLocationWeatherView: View {
    @ObservedObject var manager = CurrentLocationWeatherDataManager()
    
    var body: some View {
        VStack {
            if manager.location != nil {
                WeatherView(location: manager.location!)
            } else {
                VStack {
                    Spacer()
                    Text("Loading...")
                    Spacer()
                }
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
