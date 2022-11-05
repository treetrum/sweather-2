//
//  IntentHandler.swift
//  SweatherIntentsExtension
//
//  Created by Sam Davis on 21/9/20.
//  Copyright © 2020 Sam Davis. All rights reserved.
//

import Intents
import CoreData

func transformDataPointEntry(entry: DataPointEntry) -> DataPoint {
    let p = DataPoint(identifier: entry.name, display: entry.name)
    p.dataPoint = entry.point
    return p
}

func transformCustomLocation(location: SavedLocation) -> CustomLocation {
    let name = location.name ?? "Unknown"
    let l = CustomLocation(identifier: name, display: name)
    l.state = location.state ?? ""
    l.postcode = location.postcode ?? ""
    l.locationId = String(location.id)
    return l
}

struct DataPointEntry {
    let name: String
    let point: DataPoints
    
    static let entries: [DataPoints: DataPointEntry] = [
        .unknown: DataPointEntry(name: "None", point: .unknown),
        .actualTemperature: DataPointEntry(name: "Actual Temperature", point: .actualTemperature),
        .apparentTemperature: DataPointEntry(name: "Feels Like", point: .apparentTemperature),
        .highAndLow: DataPointEntry(name: "High & Low", point: .highAndLow),
        .humidity: DataPointEntry(name: "Humidity", point: .humidity),
        .location: DataPointEntry(name: "Location", point: .location),
        .summary: DataPointEntry(name: "Summary", point: .summary),
        .rain: DataPointEntry(name: "Rain", point: .rain),
    ]
        
    static let defaultEntries: [DataPointEntry] = [
        entries[.highAndLow]!,
        entries[.location]!,
        entries[.unknown]!
    ]
    
    static let testingEntries: [DataPointEntry] = [
        entries[.highAndLow]!,
        entries[.actualTemperature]!,
        entries[.location]!,
    ]
}

class IntentHandler: INExtension, SweatherWidgetConfigurationIntentHandling {
    func provideDataPointsOptionsCollection(for intent: SweatherWidgetConfigurationIntent, with completion: @escaping (INObjectCollection<DataPoint>?, Error?) -> Void) {
        let dataPoints = DataPointEntry.entries.values.map(transformDataPointEntry)
        let collection = INObjectCollection(items: dataPoints)
        completion(collection, nil)
    }

    func defaultDataPoints(for intent: SweatherWidgetConfigurationIntent) -> [DataPoint]? {
        return DataPointEntry.defaultEntries.map(transformDataPointEntry)
    }
    
    func provideCustomLocationOptionsCollection(for intent: SweatherWidgetConfigurationIntent, with completion: @escaping (INObjectCollection<CustomLocation>?, Error?) -> Void) {
        let locations = PersistentStorage.getSavedLocations()
        let options: [CustomLocation] = locations.map(transformCustomLocation)
        completion(INObjectCollection(items: options), nil);
    }
    
    func defaultCustomLocation(for intent: SweatherWidgetConfigurationIntent) -> CustomLocation? {
        let locations = PersistentStorage.getSavedLocations()
        let options: [CustomLocation] = locations.map(transformCustomLocation)
        return options.first
    }
    
    override func handler(for intent: INIntent) -> Any {
        // This is the default implementation.  If you want different objects to handle different intents,
        // you can override this and return the handler you want for that particular intent.
        return self
    }
}
