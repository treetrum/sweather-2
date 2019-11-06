//
//  SWWeather.swift
//  sweather-2
//
//  Created by Sam Davis on 29/10/19.
//  Copyright © 2019 Sam Davis. All rights reserved.
//

import Foundation

struct SWWeather {
    
    let location: WWLocation
    
    struct Overview {
        
        struct Precis {
            let precis: String
            let precisCode: String
        }

        let precis: Precis
        
        struct Temperature {
            let max: Float
            let min: Float
            let apparent: Float
            let actual: Float
        }
        
        let temperature: Temperature
        
        struct Rainfall {
            let probability: Float
            let rangeCode: String
        }
        
        let rainfall: Rainfall
        
        struct SunriseSunset {
            let rise: String
            let set: String
            let firstLight: String
            let lastLight: String
        }
        
        let sunrisesunset: SunriseSunset
        
        struct Humidity {
            let percent: Float
        }
        
        let humidity: Humidity

    }
    
    let overview: Overview

}
