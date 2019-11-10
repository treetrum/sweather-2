//
//  Hours.swift
//  sweather-2
//
//  Created by Sam Davis on 10/11/19.
//  Copyright © 2019 Sam Davis. All rights reserved.
//

import SwiftUI

struct Hours: View {
    
    let weather: SWWeather
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(weather.hours, id: \.dateTime) { (hour: SWWeather.Hour) in
                    VStack {
                        Text("\(hour.temperature?.roundToFloor() ?? "0")°").fixedSize().padding(.bottom, 5)
                        Text("\(hour.dateTime?.prettyHourName() ?? "-")").fixedSize().font(.footnote)
                    }.frame(width: 50)
                }
            }.padding(.horizontal)
        }
        
    }
}

struct Hours_Previews: PreviewProvider {
    static var previews: some View {
        Hours(weather: SampleWeatherData())
    }
}
