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
    
    func getWeather(config: SweatherWidgetConfigurationIntent, completion: @escaping (SWWeather?) -> Void) {
        
        let api = WillyWeatherAPI()
    
        if (locationHelper.manager == nil) {
            locationHelper.manager = CLLocationManager()
        }
        
        if (config.currentLocation == 1 || config.customLocation == nil) {
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
        } else {
            let locationId = Int64(config.customLocation!.locationId!)!
            api.getWeatherForLocation(location: locationId) { (data, error) in
                if let weatherData = data {
                    completion(SWWeather(weather: weatherData))
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
            getWeather(config: configuration) { (weather) in
                if let data = weather {
                    completion(WeatherEntry(date: Date(), weatherData: data, configuration: configuration, family: context.family))
                }
            }
        }
    }
    
    func getTimeline(for configuration: SweatherWidgetConfigurationIntent, in context: Context, completion: @escaping (Timeline<WeatherEntry>) -> Void) {

        let currentDate = Date()
        let refreshDate = Calendar.current.date(byAdding: .minute, value: 15, to: currentDate)!
        
        getWeather(config: configuration) { (weatherData) in
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
    
    func Icon(size: CGFloat = 30) -> some View {
        Image("resscaled-\(entry.weatherData.getPrecisImageCode())")
            .resizable()
            .frame(width: size, height: size)
            .foregroundColor(.white)
    }
    
    func Temperature() -> some View {
        var value: Float?
        if entry.configuration.feels_like == 1 {
            value = entry.weatherData.temperature.apparent
        } else {
            value = entry.weatherData.temperature.actual
        }
        return Text("\(value?.roundToSingleDecimalString() ?? "0")°")
            .font(entry.family == .systemSmall ? .title2 : .title)
    }
    
    func DataPoints(alignment: HorizontalAlignment = .leading, textAlign: TextAlignment = .leading) -> some View {
        let precis: String = entry.weatherData.precis.precis ?? ""
        let min: Int = entry.weatherData.temperature.min ?? 0
        let max: Int = entry.weatherData.temperature.max ?? 0
        let name: String = entry.weatherData.location.name
        let feelsLike = entry.weatherData.temperature.apparent?.roundToSingleDecimalString() ?? ""
        let actual = entry.weatherData.temperature.actual?.roundToSingleDecimalString() ?? ""
        let humidity = entry.weatherData.humidity.percent ?? 0
        let rain = entry.weatherData.rainfall.amount
        let datapoints = entry.configuration.DataPoints ?? DataPointEntry.testingEntries.map(transformDataPointEntry)
        
        return VStack(alignment: alignment, spacing: 2) {
            ForEach(datapoints, id: \.self) { (point: DataPoint) in
                switch point.dataPoint {
                case DataPoints.apparentTemperature:
                    Text("Feels Like: \(feelsLike)°")
                case DataPoints.actualTemperature:
                    Text("Actual: \(actual)°")
                case DataPoints.highAndLow:
                    HStack {
                        Image(systemName: "arrow.down").scaleEffect(0.8)
                        Text("\(min)°").padding(.leading, -6)
                        Image(systemName: "arrow.up").scaleEffect(0.8)
                        Text("\(max)°").padding(.leading, -6)
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
        .multilineTextAlignment(textAlign)
        .opacity(0.75)
        .font(.system(size: 12))
    }
    
    func HorizontalDayForecast() -> some View {
        let daysToShow = entry.weatherData.days[..<6]

        return HStack {
            ForEach(daysToShow, id: \.dateTime) { (day: SWWeather.Day) in
                VStack {
                    HStack(alignment: .top, spacing: 5) {
                        Text("\(day.max ?? 0)")
                        Text("\(day.min ?? 0)").opacity(0.5)
                    }
                        .font(.caption)
                    Image("resscaled-\(day.precisCode ?? "")")
                        .resizable()
                        .frame(width: 25, height: 25).padding(-2)
                    Text((day.dateTime?.prettyShortDayName() ?? "").uppercased())
                        .font(.system(size: 10))
                        .opacity(0.8)
                    
                }
                if day.dateTime != daysToShow.last?.dateTime {
                    Spacer()
                }
            }
        }
        .padding(.horizontal, 5)
    }
    
    func HorizontalHourForecast() -> some View {
        let hours = self.entry.weatherData.hours[..<6]
        return HStack {
            ForEach(hours, id: \.dateTime) { (hour: SWWeather.Hour) in
                VStack {
                    Text("\(hour.temperature?.roundToSingleDecimalString() ?? "0")")
                        .font(.caption)
                    Image("resscaled-\(hour.precisCode ?? "")")
                        .resizable()
                        .frame(width: 25, height: 25).padding(-2)
                    Text(hour.dateTime?.prettyHourName() ?? "")
                        .font(.system(size: 10))
                        .opacity(0.8)
                }
                if hour.dateTime != hours.last?.dateTime {
                    Spacer()
                }
            }
        }.padding(.horizontal, 5)
    }
    
    func smallLayout() -> some View {
        Group {
            Icon()
            Spacer()
            Temperature()
            Spacer().frame(height: 4)
            DataPoints()
        }
    }
    
    func mediumLayout() -> some View {
        VStack {
            HStack {
                Icon(size: 30).padding(.trailing, 5)
                Temperature()
                Spacer()
                DataPoints(alignment: .trailing, textAlign: .trailing)
            }
            Spacer()
            switch entry.configuration.forecast {
            case ForecastType.hourly:
                HorizontalHourForecast()
            case ForecastType.daily:
                HorizontalDayForecast()
            default:
                HorizontalHourForecast()
            }
        }
    }

    var body: some View {
        ZStack {
            BackgroundGradient(timePeriod: entry.weatherData.getTimePeriod())
            VStack(alignment: .leading) {
                switch entry.family {
                case .systemSmall:
                    smallLayout()
                case .systemMedium:
                    mediumLayout()
                default:
                    fatalError("Unknown widget size accessed")
                }
            }
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            .padding()
            .frame(minWidth: 0, maxWidth: .infinity)
            .frame(minHeight: 0, maxHeight: .infinity)
            .foregroundColor(Color.white)
        }
//        .redacted(reason: .placeholder)
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
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct SweatherWidget_Previews: PreviewProvider {
    
    static let date = Date()
    static let data = SampleWeatherData()
    static let config = SweatherWidgetConfigurationIntent()

    static var previews: some View {
        ForEach([
            WidgetFamily.systemSmall,
            WidgetFamily.systemMedium
        ], id: \.self) { family in
            SweatherWidgetEntryView(entry: WeatherEntry(date: date, weatherData: data, configuration: config, family: family))
                .previewContext(WidgetPreviewContext(family: family))
        }
    }
}
