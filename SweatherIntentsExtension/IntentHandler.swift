//
//  IntentHandler.swift
//  SweatherIntentsExtension
//
//  Created by Sam Davis on 21/9/20.
//  Copyright © 2020 Sam Davis. All rights reserved.
//

import Intents

func transformDataPointEntry(entry: DataPointEntry) -> DataPoint {
    let p = DataPoint(identifier: entry.name, display: entry.name)
    p.dataPoint = entry.point
    return p
}

struct DataPointEntry {
    let name: String
    let point: DataPoints
    
    static let allEntries = [
        DataPointEntry(name: "None", point: .unknown),                              // 0
        DataPointEntry(name: "Actual Temperature", point: .actualTemperature),      // 1
        DataPointEntry(name: "Feels Like", point: .apparentTemperature),            // 2
        DataPointEntry(name: "High & Low", point: .highAndLow),                     // 3
        DataPointEntry(name: "Humidity", point: .humidity),                         // 4
        DataPointEntry(name: "Location", point: .location),                         // 5
        DataPointEntry(name: "Summary", point: .summary),                           // 6
        DataPointEntry(name: "Rain", point: .rain),                                 // 7
    ]
    
    static let defaultEntries = [
        allEntries[3],
        allEntries[5],
        allEntries[0]
    ]
}

class IntentHandler: INExtension, SweatherWidgetConfigurationIntentHandling {
    func provideDataPointsOptionsCollection(for intent: SweatherWidgetConfigurationIntent, with completion: @escaping (INObjectCollection<DataPoint>?, Error?) -> Void) {
        let dataPoints = DataPointEntry.allEntries.map(transformDataPointEntry)
        let collection = INObjectCollection(items: dataPoints)
        completion(collection, nil)
    }

    func defaultDataPoints(for intent: SweatherWidgetConfigurationIntent) -> [DataPoint]? {
        return DataPointEntry.defaultEntries.map(transformDataPointEntry)
    }
    
    override func handler(for intent: INIntent) -> Any {
        // This is the default implementation.  If you want different objects to handle different intents,
        // you can override this and return the handler you want for that particular intent.
        return self
    }
}
