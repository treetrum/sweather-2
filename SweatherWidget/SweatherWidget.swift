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
import CoreLocation

struct WeatherTimeline: IntentTimelineProvider {

    typealias Intent = SweatherWidgetConfigurationIntent
    typealias Entry = WeatherEntry

    let locationHelper = LocationHelper()
    
    func getWeather(_ completion: @escaping (SWWeather?) -> Void) {
        
        let api = WillyWeatherAPI()
    
        if (locationHelper.manager == nil) {
            locationHelper.manager = CLLocationManager()
        }
        
        locationHelper.getLocation { (coords) in
            if let coords = coords {
                api.getLocationForCoords(coords: coords.coordinate) { (location, error) in
                    if let location = location {
                        api.getWeatherForLocation(location: location.id) { (data, error) in
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
        WeatherEntry(date: Date(), weatherData: SampleWeatherData(), configuration: SweatherWidgetConfigurationIntent())
    }
    
    func getSnapshot(for configuration: SweatherWidgetConfigurationIntent, in context: Context, completion: @escaping (WeatherEntry) -> Void) {
        if context.isPreview {
            let sampleEntry = WeatherEntry(date: Date(), weatherData: SampleWeatherData(), configuration: configuration)
            completion(sampleEntry)
        } else {
            getWeather { (weather) in
                if let data = weather {
                    completion(WeatherEntry(date: Date(), weatherData: data, configuration: configuration))
                }
            }
        }
    }
    
    func getTimeline(for configuration: SweatherWidgetConfigurationIntent, in context: Context, completion: @escaping (Timeline<WeatherEntry>) -> Void) {

        let currentDate = Date()
        let refreshDate = Calendar.current.date(byAdding: .minute, value: 15, to: currentDate)!
        
        getWeather { (weatherData) in
            if let weather = weatherData {
                let entry = WeatherEntry(date: Date(), weatherData: weather, configuration: configuration)
                let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
                completion(timeline)
            }
        }
    }
}

struct WeatherEntry: TimelineEntry {
    let date: Date
    let weatherData: SWWeather
    let configuration: SweatherWidgetConfigurationIntent
}

struct SweatherWidgetEntryView : View {
    var entry: WeatherTimeline.Entry
    var iconSize: CGFloat = 50;
    
    var temperature: some View {
        var value: Float?
        if entry.configuration.feels_like == 1 {
            value = entry.weatherData.temperature.apparent
        } else {
            value = entry.weatherData.temperature.actual
        }
        return Text("\(value?.roundToSingleDecimalString() ?? "0")°")
    }

    var body: some View {
        ZStack {
            BackgroundGradient(timePeriod: entry.weatherData.getTimePeriod())
            VStack(alignment: .leading) {
                Image(entry.weatherData.getPrecisImageCode()).resizable().frame(width: iconSize, height: iconSize).foregroundColor(.white).padding(.all, -12)
                Spacer()
                temperature.font(.title2)
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
        
        IntentConfiguration(kind: kind, intent: SweatherWidgetConfigurationIntent.self, provider: WeatherTimeline()) { entry in
            SweatherWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Forecast")
        .description("View the current weather and forecast.")
    }
}

struct SweatherWidget_Previews: PreviewProvider {
    static var previews: some View {
        SweatherWidgetEntryView(entry: WeatherEntry(date: Date(), weatherData: SampleWeatherData(), configuration: SweatherWidgetConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
