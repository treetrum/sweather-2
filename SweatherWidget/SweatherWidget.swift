//
//  SweatherWidget.swift
//  SweatherWidget
//
//  Created by Sam Davis on 19/9/20.
//  Copyright © 2020 Sam Davis. All rights reserved.
//

import WidgetKit
import SwiftUI
import Intents

struct WeatherTimeline: TimelineProvider {

    typealias Entry = WeatherEntry
    
    func getWeather(_ completion: @escaping (SWWeather?) -> Void) {
        let api = WillyWeatherAPI()
        
        LocationHelper.shared.getLocation { (coords) in
            if let coords = coords {
                api.getLocationForCoords(coords: coords.coordinate) { (location, error) in
                    if let location = location {
                        api.getWeatherForLocation(location: location.id) { (data, error) in
                            if error != nil {
                                fatalError("Something went wrong: \(error!)")
                            }
                            if let weatherData = data {
                                completion(SWWeather(weather: weatherData))
                            }
                        }
                    }
                }
            }
        }
    }
    
    func placeholder(in context: Context) -> WeatherEntry {
        WeatherEntry(date: Date(), weatherData: SampleWeatherData())
    }
    
    func getSnapshot(in context: Context, completion: @escaping (WeatherEntry) -> Void) {
        if context.isPreview {
            let sampleEntry = WeatherEntry(date: Date(), weatherData: SampleWeatherData())
            completion(sampleEntry)
        } else {
            getWeather { (weather) in
                if let data = weather {
                    completion(WeatherEntry(date: Date(), weatherData: data))
                }
            }
        }
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<WeatherEntry>) -> Void) {
        
        let currentDate = Date()
        let refreshDate = Calendar.current.date(byAdding: .minute, value: 15, to: currentDate)!
        
        getWeather { (weatherData) in
            if let weather = weatherData {
                let entry = WeatherEntry(date: Date(), weatherData: weather)
                let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
                completion(timeline)
            }
        }
    }
}

struct WeatherEntry: TimelineEntry {
    let date: Date
    let weatherData: SWWeather
}

struct SweatherWidgetEntryView : View {
    var entry: WeatherTimeline.Entry
    var iconSize: CGFloat = 50;

    var body: some View {
        ZStack {
            BackgroundGradient(timePeriod: entry.weatherData.getTimePeriod())
            VStack(alignment: .leading) {
                Image(entry.weatherData.getPrecisImageCode()).resizable().frame(width: iconSize, height: iconSize).foregroundColor(.white).padding(.all, -12)
                Spacer()
                Text("\(entry.weatherData.temperature.actual?.roundToSingleDecimalString() ?? "0")°").font(.title2)
                Spacer().frame(height: 3)
                Text("\(entry.weatherData.precis.precis ?? "")").font(.footnote)
                Spacer().frame(height: 3)
                Text("L:\(entry.weatherData.temperature.min ?? 0)° H:\(entry.weatherData.temperature.max ?? 0)°").font(.footnote)
                Spacer().frame(height: 3)
                Text("\(entry.weatherData.location.name)").font(.footnote)
            }
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                .padding()
                .frame(minWidth: 0, maxWidth: .infinity)
                .frame(minHeight: 0, maxHeight: .infinity)
                .foregroundColor(Color.white)
        }
    }
}

@main
struct SweatherWidget: Widget {
    let kind: String = "SweatherWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WeatherTimeline()) { entry in
            SweatherWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

struct SweatherWidget_Previews: PreviewProvider {
    static var previews: some View {
        SweatherWidgetEntryView(entry: WeatherEntry(date: Date(), weatherData: SampleWeatherData()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
