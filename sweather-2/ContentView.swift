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
    @State private var showingSettings: Bool = false
    @State private var showingModal: Bool = false
    
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest( entity: SavedLocation.entity(), sortDescriptors: [] ) var savedLocations: FetchedResults<SavedLocation>
    @EnvironmentObject var sessionData: SessionData
    @EnvironmentObject var appState: AppState
    @ObservedObject var weatherDataManager: WeatherDataManager = WeatherDataManager()

    var body: some View {
        GeometryReader { (geometry: GeometryProxy) in
            ZStack {
                BackgroundGradient(manager: self.weatherDataManager)
                VStack {
                    if self.sessionData.viewingCurrentLocation || self.savedLocations.count == 0 {
                        CurrentLocationWeatherView(manager: self.weatherDataManager)
                    } else {
                       if self.savedLocations.first(where: { $0.id == self.sessionData.currentLocationId }) != nil {
                            WeatherView(
                                location: WWLocation( savedLocation: self.savedLocations.first(where: { $0.id == self.sessionData.currentLocationId })!),
                                manager: self.weatherDataManager
                            )
                       }
                    }
                    BottomBar(
                        showingModal: self.$showingModal,
                        showingListView: self.$showingListView,
                        showingSettings: self.$showingSettings,
                        safeAreaOffsets: geometry.safeAreaInsets
                    )
                }.padding(.top, geometry.safeAreaInsets.top)

                CustomPopup(active: self.$appState.showDayDetail) {
                    VStack {
                        if self.appState.dayDetailDay != nil {
                            DayDetail(day: self.appState.dayDetailDay!)
                        } else {
                            EmptyView()
                        }
                    }
                }
            }
            .edgesIgnoringSafeArea(.all)
            .sheet(isPresented: self.$showingModal) {
                if (self.showingListView) {
                    LocationsListView()
                        .environment(\.managedObjectContext, self.managedObjectContext)
                        .environmentObject(self.sessionData)
                } else if (self.showingSettings) {
                    Settings()
                        .environment(\.managedObjectContext, self.managedObjectContext)
                        .environmentObject(self.sessionData)
                } else {
                    Text("ERROR")
                }
            }
            .onDisappear {
                self.weatherDataManager.destroy()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext)
            .environmentObject(SessionData())
            .environmentObject(AppState())
            .environment(\.colorScheme, .dark)
    }
}

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
