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
        WeatherEntry(date: Date(), weatherData: SampleWeatherData(), configuration: SweatherWidgetConfigurationIntent(), family: context.family)
    }
    
    func getSnapshot(for configuration: SweatherWidgetConfigurationIntent, in context: Context, completion: @escaping (WeatherEntry) -> Void) {
        if context.isPreview {
            let sampleEntry = WeatherEntry(date: Date(), weatherData: SampleWeatherData(), configuration: configuration, family: context.family)
            completion(sampleEntry)
        } else {
            getWeather { (weather) in
                if let data = weather {
                    completion(WeatherEntry(date: Date(), weatherData: data, configuration: configuration, family: context.family))
                }
            }
        }
    }
    
    func getTimeline(for configuration: SweatherWidgetConfigurationIntent, in context: Context, completion: @escaping (Timeline<WeatherEntry>) -> Void) {

        let currentDate = Date()
        let refreshDate = Calendar.current.date(byAdding: .minute, value: 15, to: currentDate)!
        
        getWeather { (weatherData) in
            if let weather = weatherData {
                let entry = WeatherEntry(date: Date(), weatherData: weather, configuration: configuration, family: context.family)
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
    let family: WidgetFamily
}

struct SweatherWidgetEntryView : View {
    var entry: WeatherTimeline.Entry
    var iconSize: CGFloat = 38;
    
    func Temperature() -> some View {
        var value: Float?
        if entry.configuration.feels_like == 1 {
            value = entry.weatherData.temperature.apparent
        } else {
            value = entry.weatherData.temperature.actual
        }
        return Text("\(value?.roundToSingleDecimalString() ?? "0")°")
    }
    
    func DataPoints() -> some View {
        let precis: String = entry.weatherData.precis.precis ?? ""
        let min: Int = entry.weatherData.temperature.min ?? 0
        let max: Int = entry.weatherData.temperature.max ?? 0
        let name: String = entry.weatherData.location.name
        let feelsLike = entry.weatherData.temperature.apparent?.roundToSingleDecimalString() ?? ""
        let actual = entry.weatherData.temperature.actual?.roundToSingleDecimalString() ?? ""
        let humidity = entry.weatherData.humidity.percent ?? 0
        let rain = entry.weatherData.rainfall.amount
        
        return VStack(alignment: .leading, spacing: 2) {
            ForEach(entry.configuration.DataPoints!, id: \.self) { point in
                switch point.dataPoint {
                case DataPoints.apparentTemperature:
                    Text("Feels Like: \(feelsLike)°")
                case DataPoints.actualTemperature:
                    Text("Actual: \(actual)°")
                case DataPoints.highAndLow:
                    HStack {
                        Image(systemName: "arrow.down")
                        Text("\(min)°").padding(.leading, -5)
                        Image(systemName: "arrow.up")
                        Text("\(max)°").padding(.leading, -5)
                    }
                case DataPoints.humidity:
                    Text("Humidity: \(humidity)%")
                case DataPoints.location:
                    Text(name)
                case DataPoints.summary:
                    Text(precis)
                case DataPoints.rain:
                    Text("Rain: \(rain)")
                default:
                    EmptyView()
                }
            }
        }
        .opacity(0.75)
        .font(.footnote)
    }

    var body: some View {
        let weatherData = entry.weatherData
        ZStack {
            BackgroundGradient(timePeriod: weatherData.getTimePeriod())
            VStack(alignment: .leading) {
                Image("left-\(weatherData.getPrecisImageCode())")
                    .resizable()
                    .frame(width: iconSize, height: iconSize)
                    .foregroundColor(.white)
                Spacer()
                Temperature().font(.title2)
                Spacer().frame(height: 4)
                DataPoints()
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
        .supportedFamilies([.systemSmall])
    }
}

struct SweatherWidget_Previews: PreviewProvider {
    
    static let date = Date()
    static let data = SampleWeatherData()
    static let config = SweatherWidgetConfigurationIntent()
    static let entry = WeatherEntry(date: date, weatherData: data, configuration: config, family: .systemSmall)

    static var previews: some View {
        SweatherWidgetEntryView(entry: entry).previewContext(WidgetPreviewContext(family: .systemSmall))
        SweatherWidgetEntryView(entry: entry).previewContext(WidgetPreviewContext(family: .systemMedium))
        SweatherWidgetEntryView(entry: entry).previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}
