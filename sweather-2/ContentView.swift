//
//  ContentView.swift
//  sweather-2
//
//  Created by Sam Davis on 23/10/19.
//  Copyright © 2019 Sam Davis. All rights reserved.
//

import SwiftUI
import SwiftUIX
import Combine
import CoreData
import CoreLocation

extension WWLocation {
    init(savedLocation: SavedLocation) {
        self = WWLocation(id: Int(savedLocation.id), name: savedLocation.name!, region: savedLocation.region!, state: savedLocation.state!, postcode: savedLocation.postcode!)
    }
}

extension Float {
    func roundToSingleDecimalString() -> String {
        return String(format: "%.1f", self)
    }
}

struct ContentView: View {
    
    @State private var showingListView: Bool = false
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest( entity: SavedLocation.entity(), sortDescriptors: [] ) var savedLocations: FetchedResults<SavedLocation>
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    self.showingListView = true
                }, label: {
                    Text("Locations")
                })
                Spacer()
                Text("Warnings")
            }.padding(EdgeInsets(.all, 20))
            
            if SessionData.viewingCurrentLocation || savedLocations.count == 0 {
                CurrentLocationWeatherView()
            } else {
                if savedLocations.first(where: { $0.id == SessionData.currentLocationId }) != nil {
                    WeatherView(location: WWLocation(savedLocation: savedLocations.first(where: { $0.id == SessionData.currentLocationId })! ))
                }
            }
        
        }
        .sheet(isPresented: self.$showingListView) {
            LocationsListView().environment(\.managedObjectContext, self.managedObjectContext)
        }
    }
}

struct NoLocationsView: View {
    var body: some View {
        VStack {
            Spacer()
            Text("You need to add a location")
            Spacer()
        }
    }
}

struct CurrentLocationWeatherView: View {
    
    @ObservedObject var manager = CurrentLocationWeatherDataManager()
    
    var body: some View {
        VStack {
            if manager.location != nil {
                WeatherView(location: manager.location!, isCurrentLocation: true)
            } else {
                VStack {
                    Spacer()
                    Text("Loading...")
                    Spacer()
                }
            }
        }.onDisappear {
            self.manager.destroy()
        }
    }
    
}

struct WeatherView: View {
    let location: WWLocation
    let isCurrentLocation: Bool
    
    @ObservedObject var weatherDataManager: WeatherDataManager
    
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    init(location: WWLocation, isCurrentLocation: Bool = false) {
        self.location = location
        self.isCurrentLocation = isCurrentLocation
        self.weatherDataManager = WeatherDataManager(locationId: location.id)
    }
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                if isCurrentLocation {
                    Image(systemName: "location.fill")
                }
                Text(location.name).font(.headline)
                Spacer()
            }
            
            if weatherDataManager.weatherData != nil {
                Spacer().frame(height: 50)
                if colorScheme == ColorScheme.dark {
                    Image(
                        WillyWeatherAPI.getPrecisImageCode(
                            forPrecisCode: weatherDataManager.weatherData!.forecasts.precis.days[0].entries[0].precisCode,
                            and: weatherDataManager.weatherData!.forecasts.sunrisesunset.days[0].entries[0])
                    )
                } else {
                    Image(
                        WillyWeatherAPI.getPrecisImageCode(
                            forPrecisCode: weatherDataManager.weatherData!.forecasts.precis.days[0].entries[0].precisCode,
                            and: weatherDataManager.weatherData!.forecasts.sunrisesunset.days[0].entries[0])
                    ).colorInvert()
                }
                
                Spacer().frame(height: 50)
                Text("\(weatherDataManager.weatherData!.forecasts.precis.days[0].entries[0].precis)")
                Spacer().frame(height: 10)
                Text("\(weatherDataManager.weatherData!.observational.observations.temperature.temperature.roundToSingleDecimalString())°").font(.title)
                Spacer().frame(height: 10)
                Text("Feels like \(weatherDataManager.weatherData!.observational.observations.temperature.apparentTemperature!.roundToSingleDecimalString())°")
                Spacer().frame(height: 10)
                HStack {
                    Image(systemName: "arrow.up")
                    Text("\(weatherDataManager.weatherData!.forecasts.weather.days[0].entries[0].max)")
                    Spacer().frame(width: 20)
                    Image(systemName: "arrow.down")
                    Text("\(weatherDataManager.weatherData!.forecasts.weather.days[0].entries[0].min)")
                }
            } else {
                Spacer()
                Text("Loading")
            }
            Spacer()
        }.onDisappear {
            self.weatherDataManager.destroy()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
