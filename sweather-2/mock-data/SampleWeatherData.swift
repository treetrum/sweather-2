//
//  SampleWeatherData.swift
//  sweather-2
//
//  Created by Sam Davis on 9/11/19.
//  Copyright © 2019 Sam Davis. All rights reserved.
//

import Foundation

class SampleWeatherData: SWWeather {
    init() {
        super.init(weather: decodeLocalJSON("sample-weather-data", type: WWWeatherData.self)!)
    }
}
