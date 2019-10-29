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
            if savedLocations.count > 0 {
                if SessionData.viewingCurrentLocation {
                    CurrentWeatherView()
                } else {
                    WeatherView(location: WWLocation(savedLocation: savedLocations.first(where: { $0.id == SessionData.currentLocationId })! ))
                }
            } else {
                NoLocationsView()
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

class LocationManager: NSObject, CLLocationManagerDelegate, ObservableObject {
    
    private let manager: CLLocationManager = CLLocationManager()

    @Published var lastKnownLocation: CLLocation?
    
    override init() {
        super.init()
        self.startUpdating()
    }
    
    func startUpdating() {
        self.manager.delegate = self
        self.manager.requestWhenInUseAuthorization()
        self.manager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lastKnownLocation = locations.last
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            manager.startUpdatingLocation()
        }
    }
}

struct CurrentWeatherView: View {
    
    @ObservedObject var locationManager = LocationManager()
    @ObservedObject var locationWeatherManager = LocationWeatherDataManager()
    
    var body: some View {
        VStack {
            if locationManager.lastKnownLocation != nil {
                
                if locationWeatherManager.location != nil {
                    WeatherView(location: locationWeatherManager.location!)
                } else {
                    Text("Finding weather source for your coords").onAppear(perform: onGotLocation)
                }
            } else {
                Text("Getting your location")
            }
        }
    }
    
    func onGotLocation() {
        self.locationWeatherManager.getLocationForCoords(self.locationManager.lastKnownLocation!.coordinate)
    }
    
}

struct WeatherView: View {
    let location: WWLocation
    
    @ObservedObject var weatherDataManager: WeatherDataManager
    
    init(location: WWLocation) {
        self.location = location
        self.weatherDataManager = WeatherDataManager(locationId: location.id)
    }
    
    var body: some View {
        VStack {
            Text(location.name).font(.title)
            Spacer()
            if weatherDataManager.weatherData != nil {
                Text("\(weatherDataManager.weatherData!.forecasts.precis.days[0].entries[0].precis)")
                Text("\(weatherDataManager.weatherData!.observational.observations.temperature.temperature.roundToSingleDecimalString())°")
            } else {
                Text("Loading")
            }
            Spacer()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
