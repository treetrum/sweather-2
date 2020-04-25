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
    var timePeriod: SWWeather.SWTimePeriod = .isDayTime

    var gradients: [[Color]] = [
        [Color.init(UIColor(hexString: "C92D2D")), Color.init(UIColor(hexString: "763BCD"))],
        [Color.init(UIColor(hexString: "46AEF3")), Color.init(UIColor(hexString: "910DA7"))],
        [Color.init(UIColor(hexString: "FFCB41")), Color.init(UIColor(hexString: "FB6914"))],
        [Color.init(UIColor(hexString: "FB6914")), Color.init(UIColor(hexString: "B300AC"))],
        [Color.init(UIColor(hexString: "272394")), Color.init(UIColor(hexString: "16A2FF"))],
        [Color.init(UIColor(hexString: "06113B")), Color.init(UIColor(hexString: "4A30BF"))]
    ]
    
    init(manager: WeatherDataManager) {
        self.manager = manager;
        if let weatherData = manager.simpleWeatherData {
            self.timePeriod = weatherData.getTimePeriod()
        }
    }
    
    var body: some View {
        ZStack {
            // Can't use a foreach here or else zIndex won't work
            GradientLayer(colors: self.gradients[0], active: 0 == self.timePeriod.rawValue)
            GradientLayer(colors: self.gradients[1], active: 1 == self.timePeriod.rawValue)
            GradientLayer(colors: self.gradients[2], active: 2 == self.timePeriod.rawValue)
            GradientLayer(colors: self.gradients[3], active: 3 == self.timePeriod.rawValue)
            GradientLayer(colors: self.gradients[4], active: 4 == self.timePeriod.rawValue)
            GradientLayer(colors: self.gradients[5], active: 5 == self.timePeriod.rawValue)
        }
    }
}

struct GradientLayer: View {
    let colors: [Color]
    let active: Bool
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: self.colors),
            startPoint: UnitPoint(x: 0, y: 0),
            endPoint: UnitPoint(x: 1, y: 1)
        )
            .zIndex(self.active ? 1 : 0)
            .opacity(self.active ? 1 : 0)
            .animation(
                Animation.easeInOut(duration: 1)
                    .delay(self.active ? 0 : 1)
            )
    }
}

struct BackgroundGradient_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext)
            .environmentObject(SessionData())
    }
}

//struct BackgroundGradient_Previews: PreviewProvider {
//    static var previews: some View {
//        Text("No preview for this view")
//    }
//}
