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

struct ContentView: View {
    
    @State private var showingListView: Bool = false
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest( entity: SavedLocation.entity(), sortDescriptors: [] ) var savedLocations: FetchedResults<SavedLocation>
    @EnvironmentObject var sessionData: SessionData
    
    var body: some View {
        ZStack(alignment: .top) {

            
            if sessionData.viewingCurrentLocation || savedLocations.count == 0 {
                CurrentLocationWeatherView()
            } else {
                if savedLocations.first(where: { $0.id == sessionData.currentLocationId }) != nil {
                    WeatherView(location: WWLocation(savedLocation: savedLocations.first(where: { $0.id == sessionData.currentLocationId })! ))
                }
            }
            
            HStack {
                Button(action: {
                    self.showingListView = true
                }, label: {
                    Image(systemName: "pin")
                })
                Spacer()
                Image(systemName: "exclamationmark.triangle")
            }.padding(.all, 20).padding(.top, 10)
        
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
            .environment(\.managedObjectContext, (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext)
            .environmentObject(SessionData())
    }
}
