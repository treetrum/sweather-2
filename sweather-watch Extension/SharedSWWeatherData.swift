//
//  SharedSWWeatherData.swift
//  sweather-watch Extension
//
//  Created by Sam Davis on 9/2/20.
//  Copyright © 2020 Sam Davis. All rights reserved.
//

import Foundation

class SharedSWWeatherData {
    static var shared = SharedSWWeatherData()
    var weatherData: SWWeather?
}
