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

class SearchDataManger: ObservableObject {

    let api = WillyWeatherAPI()

    @Published var results: [WWLocation] = []
    
    func search(query: String) {
        api.searchForLocationWithQuery(query: query) { (results, error) in
            guard let results = results else { return }
            DispatchQueue.main.async {
                self.results = results
                print("Got results \(results)")
            }
        }
    }
}

class WeatherDataManager: ObservableObject {
    let api = WillyWeatherAPI()
    
    @Published var weatherData: WWWeatherData?
    
    init(locationId: Int) {
        getWeatherData(locationId: locationId)
    }
    
    func getWeatherData(locationId: Int) {
        api.getWeatherForLocation(location: locationId) { (weatherData, error) in
            guard let weatherData = weatherData else { return }
            DispatchQueue.main.async {
                self.weatherData = weatherData
            }
        }
    }
}

struct ContentView: View {
    
    @State private var showModal: Bool = false
    
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @FetchRequest(
        entity: SavedLocation.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \SavedLocation.name, ascending: true)
        ]
    ) var savedLocations: FetchedResults<SavedLocation>
    
    var body: some View {
        VStack {
            
            HStack {
                Button(action: {
                    self.showModal = true
                }, label: {
                    Text("Locations")
                }).sheet(isPresented: self.$showModal) {
                    LocationsView(
                        savedLocations: self.savedLocations.map{ WWLocation(savedLocation: $0) })
                        .environment(\.managedObjectContext, self.managedObjectContext)
                }
                Spacer()
                Text("Warnings")
            }.padding(EdgeInsets(.all, 20))
            
            if savedLocations.count > 0 {
                WeatherSwiper(views: savedLocations.map{ WeatherView(location: WWLocation(savedLocation: $0)) })
            } else {
                VStack {
                    Spacer()
                    Text("You need to add a location")
                    Spacer()
                }
            }
            
            Text("Count: \(savedLocations.count)")
        }
    }
}

struct WeatherSwiper: View {
//    var locations: [WWLocation]
    var views: [WeatherView]
    
//    @Environment(\.managedObjectContext) var managedObjectContext
    
//    @FetchRequest(
//        entity: SavedLocation.entity(),
//        sortDescriptors: [
//            NSSortDescriptor(keyPath: \SavedLocation.name, ascending: true)
//        ]
//    ) var savedLocations: FetchedResults<SavedLocation>
    
    var body: some View {
//        PageView(locations.map { WeatherView(location: $0) })
//        PageView(savedLocations.map { Text("\($0.name!)") })
//        PageView([Text("test"), Text("Test 2")])
        PageView(self.views)
        
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
            Text(location.name)
            Text(weatherDataManager.weatherData != nil ? "\(weatherDataManager.weatherData!.observational.observations.temperature.temperature.roundToSingleDecimalString())°" : "Loading")
        }
    }
}

struct LocationsView: View {
//    @Environment(\.presentationMode) var presentationMode
//    @Environment(\.managedObjectContext) var managedObjectContext
    
//    @State var showAddLocationView: Bool = false
    
    var savedLocations: [WWLocation]

    var body: some View {
        NavigationView {
            List {
                ForEach(savedLocations, id: \.id) { location in
                    LocationRow(location: location)
                }
//                .onDelete(perform: removeSavedLocations)
            }
            .navigationBarTitle(Text("Locations"), displayMode: .inline)
            .navigationBarItems(leading: Button(action: {
//                self.presentationMode.wrappedValue.dismiss()
            }) {
                Text("Done")
            }, trailing: Button(action: {
//                self.showAddLocationView = true;
            }, label: {
                Image(systemName: "plus")
            }))
//                .sheet(isPresented: self.$showAddLocationView) {
//                AddLocationView().environment(\.managedObjectContext, self.managedObjectContext)
//            }
        }
    }
    
//    func removeSavedLocations(at offsets: IndexSet) {
//        for index in offsets {
//            let location = savedLocations[index]
//            managedObjectContext.delete(location)
//        }
//        do {
//            try managedObjectContext.save()
//        } catch {
//            print("Could not save core data model")
//        }
//    }
}

struct AddLocationView: View {
    @State var searchValue: String = "";
    @State var searching: Bool = false;
    
    @ObservedObject var searchManager = SearchDataManger()
    
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) var managedObjectContext

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    TextField("Location", text: self.$searchValue)
                    Button(action: handleSearch) {
                        Text("Search")
                    }
                }.padding(.all, 16).padding(.bottom, 0)
                List {
                    ForEach(self.searchManager.results, id: \.id) { location in
                        Button(action: {
                            let newLocation = SavedLocation(context: self.managedObjectContext)
                            newLocation.id = Int16(location.id)
                            newLocation.name = location.name
                            newLocation.postcode = location.postcode
                            newLocation.region = location.region
                            newLocation.state = location.state
                            
                            do {
                                try self.managedObjectContext.save()
                            } catch {
                                print(error)
                            }
                            
                            self.presentationMode.wrappedValue.dismiss()
                            
                        }) {
                            LocationRow(location: location)
                        }
                    }
                }
            }
            .navigationBarTitle("Add Location", displayMode: .inline)
        }
        
    }
    
    func handleSearch() {
        self.searching = true
        self.searchManager.search(query: searchValue)
    }
}

struct LocationRow: View {
    
    var location: WWLocation
    
    init(location: WWLocation) {
        self.location = location
    }

    var body: some View {
        Text("\(location.name), \(location.postcode)")
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        AddLocationView()
    }
}
