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
    @EnvironmentObject var appState: AppState

    let weather: SWWeather
    
    @Environment(\.horizontalSizeClass) var sizeClass
    var isIpad: Bool {
        get {
            if let size = sizeClass {
                return size == .regular
            } else {
                return false
            }
        }
    }
    
    var body: some View {
        VStack {
            if isIpad {
                // iPad
                HStack(spacing: 5) {
                    ForEach(weather.days.indices) { index in
                        Button(action: {
                            self.appState.showDayDetail(self.weather.days[index])
                        }) {
                            Day(day: self.weather.days[index])
                        }
//                            .frame(maxWidth: .infinity)
                            .padding(.vertical)
//                            .background(Color.white.opacity(0.1))
                        if (index != self.weather.days.count - 1) {
                            Spacer()
                        }
                    }
                }.padding(.horizontal)
            } else {
                // iPhone
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 25) {
                        ForEach(weather.days, id: \.dateTime) { (day: SWWeather.Day) in
                            Button(action: {
                                self.appState.showDayDetail(day)
                            }) {
                                Day(day: day)
                            }
                                .frame(maxWidth: .infinity)
//                                .padding()
//                                .background(Color.white.opacity(0.1))
                        }
                    }.padding(.horizontal)
                }
            }
        }.foregroundColor(Color.white)
    }
}

struct Day: View {
    let day: SWWeather.Day
    
    @Environment(\.horizontalSizeClass) var sizeClass
    var isIpad: Bool {
        get {
            if let size = sizeClass {
                return size == .regular
            } else {
                return false
            }
        }
    }

    var body: some View {
        VStack {
            HStack {
                Group {
                    Text("\(day.max ?? 0)")
                    Text("\(day.min ?? 0)").opacity(0.5)
                }
                    .fixedSize()
                    .font(.system(size: isIpad ? 20 : 16))
            }.padding(.bottom, -10)
            Image(day.precisCode ?? "fine")
                .resizable()
                .frame(
                    width: isIpad ? 60 : 50,
                    height: isIpad ? 60 : 50
                )
            Text("\(day.dateTime?.prettyDayName() ?? "-")")
                .fixedSize()
                .font(isIpad ? .system(size: 14) : .footnote)
                .opacity(0.5)
        }
        .multilineTextAlignment(.center)
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
