//
//  ContentView.swift
//  sweather-2
//
//  Created by Sam Davis on 23/10/19.
//  Copyright © 2019 Sam Davis. All rights reserved.
//

import SwiftUI
import Combine
import CoreData
import CoreLocation

extension WWLocation {
    init(savedLocation: SavedLocation) {
        self = WWLocation(
            id: Int(savedLocation.id),
            name: savedLocation.name!,
            region: savedLocation.region!,
            state: savedLocation.state!,
            postcode: savedLocation.postcode!
        )
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
    @EnvironmentObject var sessionData: SessionData
    
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
            }.padding(.all, 20)
            
            if sessionData.viewingCurrentLocation || savedLocations.count == 0 {
                CurrentLocationWeatherView()
            } else {
                if savedLocations.first(where: { $0.id == sessionData.currentLocationId }) != nil {
                    WeatherView(location: WWLocation(savedLocation: savedLocations.first(where: { $0.id == sessionData.currentLocationId })! ))
                }
            }
        
        }
        .sheet(isPresented: self.$showingListView) {
            LocationsListView()
                .environment(\.managedObjectContext, self.managedObjectContext)
                .environmentObject(self.sessionData)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
