//
//  DayDetail.swift
//  sweather-2
//
//  Created by Sam Davis on 25/4/20.
//  Copyright © 2020 Sam Davis. All rights reserved.
//

import SwiftUI

struct DayDetail: View {
    var day: SWWeather.Day
    var body: some View {
        VStack {
            Text("\(day.dateTime?.prettyDayName() ?? "No Day Name Available")")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.bottom, 10)
            Text("\(day.regionPrecis ?? day.precis ?? "Extended weather data unavailable")")
                .multilineTextAlignment(.center)
                .opacity(0.8)
                .font(Font.system(size: 15))
        }.frame(maxWidth: .infinity)
    }
}

struct DayDetail_Previews: PreviewProvider {
    static var previews: some View {
        CustomPopup(active: Binding.constant(true)) {
            DayDetail(day: SampleWeatherData.fromWW.days.first!)
        }.environment(\.colorScheme, .dark).edgesIgnoringSafeArea(.all)
    }
}
