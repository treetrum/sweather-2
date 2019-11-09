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
            HStack {
                ForEach(weather.days, id: \.dateTime) { (day: SWWeather.Day) in
                    VStack {
                        HStack {
                            Text("\(day.max ?? 0)").fixedSize().font(.headline)
                            Text("\(day.min ?? 0)").fixedSize()
                        }
                        if self.colorScheme == .dark {
                            Image(day.precisCode ?? "fine").resizable().frame(width: 50, height: 50)
                        } else {
                            Image(day.precisCode ?? "fine").resizable().frame(width: 50, height: 50).colorInvert()
                        }
                        
                        Text("\(day.dateTime?.prettyDayName() ?? "-")").font(.footnote)
                    }
                    .frame(width: 75)
                    .multilineTextAlignment(.center)
                }
            }.padding(.horizontal)
        }
    }
}

struct Days_Previews: PreviewProvider {
    static var previews: some View {
        Days(weather: SampleWeatherData())
    }
}
