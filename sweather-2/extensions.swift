//
//  extensions.swift
//  sweather-2
//
//  Created by Sam Davis on 10/11/19.
//  Copyright © 2019 Sam Davis. All rights reserved.
//

import Foundation

extension Date {
    
    func prettyDayName() -> String {
        if (Calendar.current.isDateInToday(self)) {
            return "Today"
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: self)
    }
    
    func prettyHourName() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "ha"
        
        let str = formatter.string(from: self)
        if str == "12am" {
            return self.prettyDayName()
        } else {
            return str
        }
    }
}

extension WWLocation {
    init(savedLocation: SavedLocation) {
        self = WWLocation(
            id: Int(savedLocation.id),
            name: savedLocation.name!,
            region: savedLocation.region!,
            state: savedLocation.state!,
            postcode: savedLocation.postcode!
        )
    }
}

extension Float {
    func roundToSingleDecimalString() -> String {
        return String(format: "%.1f", self)
    }
    func roundToFloor() -> String {
        return String(format: "%.0f", self)
    }
}
