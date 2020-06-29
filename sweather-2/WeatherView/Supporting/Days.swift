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
    @Environment(\.horizontalSizeClass) var sizeClass

    let weather: SWWeather
    
    var body: some View {
        VStack {
            if isIpad(sizeClass) {
                // iPad
                VStack(spacing: 5) {
                    ForEach(weather.days.indices) { index in
                        Button(action: {
                            self.appState.showDayDetail(self.weather.days[index])
                        }) {
                            DayRow(day: self.weather.days[index])
                                .frame(minHeight: 0, maxHeight: .infinity)
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

struct DayRow: View {
    let day: SWWeather.Day
    
    @Environment(\.horizontalSizeClass) var sizeClass
    
    var iconSize: CGFloat {
        get {
            return isIpad(sizeClass) ? 50 : 50
        }
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                HStack {
                    Group {
                        Text("\(day.max ?? 0)")
                        Text("\(day.min ?? 0)").opacity(0.5)
                    }
                    .fixedSize()
                    .font(.system(size: 18))
                    Spacer()
                }.padding(.bottom, 5)
                Text("\(day.dateTime?.prettyDayName() ?? "-")")
                    .fixedSize()
                    .font(isIpad(sizeClass) ? .system(size: 13) : .footnote)
                    .opacity(0.5)
            }
            Spacer()
            Image(day.precisCode ?? "fine")
                .resizable()
                .frame(
                    width: iconSize,
                    height: iconSize
                )
        }
        .multilineTextAlignment(.center)
    }
}

struct Day: View {
    let day: SWWeather.Day
    
    @Environment(\.horizontalSizeClass) var sizeClass

    var body: some View {
        VStack {
            HStack {
                Group {
                    Text("\(day.max ?? 0)")
                    Text("\(day.min ?? 0)").opacity(0.5)
                }
                    .fixedSize()
                    .font(.system(size: 16))
            }.padding(.bottom, -10)
            Image(day.precisCode ?? "fine")
                .resizable()
                .frame(
                    width: isIpad(sizeClass) ? 60 : 50,
                    height: isIpad(sizeClass) ? 60 : 50
                )
            Text("\(day.dateTime?.prettyDayName() ?? "-")")
                .fixedSize()
                .font(isIpad(sizeClass) ? .system(size: 13) : .footnote)
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
