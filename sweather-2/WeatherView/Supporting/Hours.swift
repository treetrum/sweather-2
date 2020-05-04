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
    
    let graphHeight = 30;
    let maskWidth: CGFloat = 15;
    let entryWidth: CGFloat = 50;
    let entryIconWidth: CGFloat = 30;
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            ZStack {
                HStack(spacing: 0) {
                    ForEach(weather.hours, id: \.dateTime) { (hour: SWWeather.Hour) in
                        VStack(spacing: 0) {
                            Text("\(hour.temperature?.roundToSingleDecimalString() ?? "0")°").font(.footnote).fixedSize().padding(.bottom, 0).padding(0)
                            Image(SWWeather.getPrecisImageCode(forPrecisCode: hour.precisCode, andIsNight: hour.night))
                                .resizable()
                                .frame(width: self.entryIconWidth, height: self.entryIconWidth)
                            Text("\(hour.dateTime?.prettyHourName() ?? "-")").fixedSize().font(.footnote).opacity(0.5).padding(0)
                        }
                        .frame(width: self.entryWidth)
                        .position(x: CGFloat(self.entryWidth / 2), y: 20 ) // Magic numbers to get the data vertically centered
                        .offset(y: CGFloat(self.convertTempToYPos(hour.temperature!)))
                    }
                }.padding(.top).frame(height: CGFloat(graphHeight + 75)) // 75 is also a magic number
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
            Hours(weather: SampleWeatherData())
        }.edgesIgnoringSafeArea(.all)
    }
}
