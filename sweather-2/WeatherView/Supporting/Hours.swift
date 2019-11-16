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
    
    let graphHeight: Int = 30;
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            ZStack {
                Path { path in
                    var currentX = 25
                    for (index, hour) in weather.hours.enumerated() {
                        let yPos = convertTempToYPos(hour.temperature!)
                        if (index == 0) {
                            path.move(to: CGPoint(x: currentX, y: yPos ))
                        } else {
                            currentX += 50
                            path.addLine(to: CGPoint(x: currentX, y: yPos ))
                        }
                    }
                }
                .strokedPath(StrokeStyle(lineWidth: 1))
                .padding([.leading, .trailing])
                .frame(height: CGFloat(graphHeight))
                .padding(.top, 1)
                .opacity(0.5)
                HStack(spacing: 0) {
                    ForEach(weather.hours, id: \.dateTime) { (hour: SWWeather.Hour) in
                        VStack(spacing: 15) {
                            Text("\(hour.temperature?.roundToFloor() ?? "0")°").fixedSize().padding(.bottom, 5).padding(0)
                            Text("\(hour.dateTime?.prettyHourName() ?? "-")").fixedSize().font(.footnote).opacity(0.5).padding(0)
                        }.frame(width: 50).position(x: 20, y: 15 ).offset(y: CGFloat(self.convertTempToYPos(hour.temperature!)))
                    }
                }.padding(.horizontal).padding(.top).frame(height: CGFloat(graphHeight + 65))
            }
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
        let roundedTemp = temp.roundToFloorInt()
        let max = getMaxTemp()
        let min = getMinTemp()
        let diff = max - min
        let tempPercentage = Float(roundedTemp - min) / Float(diff)
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
