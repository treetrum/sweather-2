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
    
    static let namedEntries: [DataPoints: DataPointEntry] = [
        .unknown: DataPointEntry(name: "None", point: .unknown),
        .actualTemperature: DataPointEntry(name: "Actual Temperature", point: .actualTemperature),
        .apparentTemperature: DataPointEntry(name: "Feels Like", point: .apparentTemperature),
        .highAndLow: DataPointEntry(name: "High & Low", point: .highAndLow),
        .humidity: DataPointEntry(name: "Humidity", point: .humidity),
        .location: DataPointEntry(name: "Location", point: .location),
        .summary: DataPointEntry(name: "Summary", point: .summary),
        .rain: DataPointEntry(name: "Rain", point: .rain),
    ]
    
    static let allEntries = namedEntries.map { _, v in v }
    
    static let defaultEntries: [DataPointEntry] = [
        namedEntries[.highAndLow]!,
        namedEntries[.location]!,
        namedEntries[.unknown]!
    ]
    
    static let testingEntries: [DataPointEntry] = [
        namedEntries[.highAndLow]!,
        namedEntries[.actualTemperature]!,
        namedEntries[.location]!,
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
