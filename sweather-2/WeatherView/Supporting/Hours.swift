//
//  Hours.swift
//  sweather-2
//
//  Created by Sam Davis on 10/11/19.
//  Copyright © 2019 Sam Davis. All rights reserved.
//

import SwiftUI

struct Hours: View {
    
    
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
    
    let weather: SWWeather

    var isWeatherKit: Bool

    var graphHeight: Int {
        get { isIpad ? 50 : 30 }
    }
    var maskWidth: CGFloat {
        get { isIpad ? 20 : 15 }
    }
    var entryWidth: CGFloat {
        get { isIpad ? 66 : 50 }
    }
    var entryIconWidth: CGFloat {
        get { isIpad ? 40 : 30 }
    }
    
    // MAGIC NUMBERS
    var yOffset: CGFloat {
        get { isIpad ? 40 : 20 }
    }
    var heightOffset: Int {
        get { isIpad ? 110 : 75 }
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            ZStack {
                HStack(spacing: 0) {
                    ForEach(weather.hours, id: \.dateTime) { (hour: SWWeather.Hour) in
                        VStack(spacing: 0) {
                            Text("\(hour.temperature?.roundToSingleDecimalString() ?? "0")°")
                                .font(self.isIpad ? .system(size: 13) : .footnote)
                                .fixedSize()
                                .padding(.bottom, 0)
                                .padding(0)
                            if isWeatherKit {
                                Image(systemName: hour.precisCode ?? "fine")
                                    .resizable()
                                    .padding(7)
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: self.entryIconWidth, height: self.entryIconWidth)
                            } else {
                                Image(SWWeather.getPrecisImageCode(forPrecisCode: hour.precisCode, andIsNight: hour.night))
                                    .resizable()
                                    .frame(width: self.entryIconWidth, height: self.entryIconWidth)
                            }
                            
                            Text("\(hour.dateTime?.prettyHourName() ?? "-")")
                                .fixedSize()
                                .font(self.isIpad ? .system(size: 13) : .footnote)
                                .opacity(0.5)
                                .padding(0)
                        }
                        .frame(width: self.entryWidth)
                            .position(x: CGFloat(self.entryWidth / 2), y: self.yOffset )
                        .offset(y: CGFloat(self.convertTempToYPos(hour.temperature!)))
                    }
                }.padding(.top).frame(height: CGFloat(graphHeight + heightOffset))
                VStack {
                    Path { path in
                        var currentX = self.entryWidth / 2
                        for (index, hour) in weather.hours.enumerated() {
                            let yPos = convertTempToYPos(hour.temperature!)
                            if (index == 0) {
                                path.move(to: CGPoint(x: Int(currentX), y: yPos ))
                            } else {
                                currentX += self.entryWidth
                                path.addLine(to: CGPoint(x: Int(currentX), y: yPos ))
                            }
                        }
                    }
                    .strokedPath(StrokeStyle(lineWidth: 1))
                    .frame(height: CGFloat(graphHeight))
                    .padding(.top, 1)
                    .opacity(0.25)
                }
                .mask(
                    HStack(spacing: 0) {
                        ForEach(weather.hours, id: \.dateTime) { (hour: SWWeather.Hour) in
                            Rectangle().frame(width: CGFloat(self.maskWidth), height: 100)
                        }.padding(.leading, CGFloat(self.entryWidth - self.maskWidth))
                    }.padding(.leading, CGFloat(self.maskWidth / 2))
                )
            }
            .padding(.horizontal, 10)
        }.foregroundColor(Color.white)
    }
    
    func getMaxTemp() -> Int {
        weather.hours.reduce(weather.hours.first!.temperature!.roundToFloorInt()) { (total, hour: SWWeather.Hour) -> Int in
            return hour.temperature!.roundToFloorInt() > total ? hour.temperature!.roundToFloorInt() : total
        }
    }
    
    func getMinTemp() -> Int {
        weather.hours.reduce(weather.hours.first!.temperature!.roundToFloorInt()) { (total, hour: SWWeather.Hour) -> Int in
            return hour.temperature!.roundToFloorInt() < total ? hour.temperature!.roundToFloorInt() : total
        }
    }
    
    func convertTempToYPos(_ temp: Float) -> Int {
        let roundedTemp = temp
        let max = getMaxTemp()
        let min = getMinTemp()
        let diff = max - min
        let tempPercentage = Float(roundedTemp - Float(min)) / Float(diff)
        let result = Float(graphHeight) * tempPercentage
        return (graphHeight - result.roundToFloorInt())
    }

}

struct Hours_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            BackgroundGradient()
            Hours(weather: SampleWeatherData.fromWeatherkit, isWeatherKit: true)
        }.edgesIgnoringSafeArea(.all).previewDisplayName("Weatherkit")
        ZStack {
            BackgroundGradient()
            Hours(weather: SampleWeatherData.fromWW, isWeatherKit: false)
        }.edgesIgnoringSafeArea(.all).previewDisplayName("Willy Weather")
    }
}
