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
    
    func prettyShortDayName() -> String {
        if (Calendar.current.isDateInToday(self)) {
            return "Today"
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: self)
    }
    
    func prettyHourName() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "ha"
        
        let str = formatter.string(from: self)
        if str.lowercased() == "12am" {
            return self.prettyShortDayName()
        } else {
            return str
        }
    }
    
    func prettyTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mma"
        return formatter.string(from: self)
    }
    
    func prettyDateTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d, yyyy h:mm a"
        return formatter.string(from: self)
    }
}

extension Float {
    func roundToSingleDecimalString() -> String {
        return String(format: "%.1f", self)
    }
    func roundToFloor() -> String {
        return String(format: "%.0f", self)
    }
    func roundToFloorInt() -> Int {
        return Int(self.roundToFloor())!
    }
}