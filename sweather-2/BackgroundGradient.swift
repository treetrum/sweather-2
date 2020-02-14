//
//  BackgroundGradient.swift
//  sweather-2
//
//  Created by Sam Davis on 9/2/20.
//  Copyright © 2020 Sam Davis. All rights reserved.
//

import SwiftUI

struct BackgroundGradient: View {
    
    @ObservedObject var manager = WeatherDataManager()
    var timePeriod: SWWeather.SWTimePeriod = .unknown

    var gradients: [[Color]] = [
        [Color.init(UIColor(hexString: "C92D2D")), Color.init(UIColor(hexString: "763BCD"))],
        [Color.init(UIColor(hexString: "46AEF3")), Color.init(UIColor(hexString: "910DA7"))],
        [Color.init(UIColor(hexString: "FFCB41")), Color.init(UIColor(hexString: "FB6914"))],
        [Color.init(UIColor(hexString: "FB6914")), Color.init(UIColor(hexString: "B300AC"))],
        [Color.init(UIColor(hexString: "272394")), Color.init(UIColor(hexString: "16A2FF"))],
        [Color.init(UIColor(hexString: "C92D2D")), Color.init(UIColor(hexString: "763BCD"))]
    ]
    
    init(manager: WeatherDataManager) {
        self.manager = manager;
        if let weatherData = manager.simpleWeatherData {
            self.timePeriod = weatherData.getTimePeriod()
        }
    }
    
    var body: some View {
        ZStack {
            ForEach(self.gradients.indices) { index in
                LinearGradient(
                    gradient: Gradient(colors: self.gradients[index]),
                    startPoint: UnitPoint(x: 0, y: 0),
                    endPoint: UnitPoint(x: 1, y: 1)
                )
                    .opacity(index == self.timePeriod.rawValue ? 1 : 0)
                    .animation(
                        Animation.easeInOut(duration: 1).delay(index == self.timePeriod.rawValue ? 0 : 1)
                    )
                    .zIndex(index == self.timePeriod.rawValue ? 100 : 0)
            }
        }
    }
}

struct BackgroundGradient_Previews: PreviewProvider {
    static var previews: some View {
        Text("No preview for this view")
    }
}
