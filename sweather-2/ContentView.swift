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
        GeometryReader { geometry in
            ZStack {
                BackgroundGradient()
                VStack {
                    if self.sessionData.viewingCurrentLocation || self.savedLocations.count == 0 {
                       CurrentLocationWeatherView()
                    } else {
                       if self.savedLocations.first(where: { $0.id == self.sessionData.currentLocationId }) != nil {
                           WeatherView(location: WWLocation( savedLocation: self.savedLocations.first(where: { $0.id == self.sessionData.currentLocationId })!))
                       }
                    }
                    BottomBar(showingListView: self.$showingListView, safeAreaOffsets: geometry.safeAreaInsets)
                }.padding(.top, geometry.safeAreaInsets.top)
            }
            .edgesIgnoringSafeArea(.all)
            .sheet(isPresented: self.$showingListView) {
                LocationsListView()
                    .environment(\.managedObjectContext, self.managedObjectContext)
                    .environmentObject(self.sessionData)
            }
        }
    }
}

struct BackgroundGradient: View {
    var body: some View {
        LinearGradient(
            gradient: Gradient(
                colors: [
                    Color.init(red: 70/255, green: 173/255, blue: 242/255),
                    Color.init(red: 145/255, green: 14/255, blue: 167/255)
                ]
            ),
            startPoint: UnitPoint(x: 0, y: 0),
            endPoint: UnitPoint(x: 1, y: 1)
        )
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext)
            .environmentObject(SessionData())
    }
}
