//
//  Days.swift
//  sweather-2
//
//  Created by Sam Davis on 10/11/19.
//  Copyright © 2019 Sam Davis. All rights reserved.
//

import SwiftUI

struct Days: View {
    
    @Environment(\.colorScheme) var colorScheme: ColorScheme

    let weather: SWWeather
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 25) {
                ForEach(weather.days, id: \.dateTime) { (day: SWWeather.Day) in
                    VStack {
                        HStack {
                            Text("\(day.max ?? 0)").fixedSize().font(.headline)
                            Text("\(day.min ?? 0)").fixedSize().opacity(0.5)
                        }.padding(.bottom, -10)
                        Image(day.precisCode ?? "fine").resizable().frame(width: 50, height: 50)
                        Text("\(day.dateTime?.prettyDayName() ?? "-")").font(.footnote).opacity(0.5)
                    }
                    .multilineTextAlignment(.center)
                }
            }.padding(.horizontal).foregroundColor(Color.white)
        }
    }
}

struct Days_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.blue
            Days(weather: SampleWeatherData())
        }
    }
}