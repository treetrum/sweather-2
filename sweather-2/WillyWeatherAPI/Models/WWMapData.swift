//
//  WWMapData.swift
//  sweather-2
//
//  Created by Sam Davis on 17/11/19.
//  Copyright © 2019 Sam Davis. All rights reserved.
//

import Foundation

struct WWMapData: Codable {
    let name: String
    let lat: Double
    let lng: Double
    let overlayPath: String
    
    struct Bounds: Codable {
        let minLat: Double
        let minLng: Double
        let maxLat: Double
        let maxLng: Double
    }
    let bounds: Bounds
    
    struct Overlay: Codable {
        let dateTime: String
        let name: String
    }
    let overlays: [Overlay]
}
