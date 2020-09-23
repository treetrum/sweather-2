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
    
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest( entity: SavedLocation.entity(), sortDescriptors: [] ) var savedLocations: FetchedResults<SavedLocation>
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var manager: WeatherDataManager
    @EnvironmentObject var searchManager: LocationSearchManager
    @ObservedObject var sessionData = SessionData.shared

    var body: some View {
        GeometryReader { (geometry: GeometryProxy) in
            ZStack {
                BackgroundGradient(timePeriod: self.manager.simpleWeatherData?.getTimePeriod() ?? .isDayTime)
                VStack {
                    if self.sessionData.viewingCurrentLocation || self.savedLocations.count == 0 {
                        CurrentLocationWeatherView()
                    } else {
                       if self.savedLocations.first(where: { $0.id == self.sessionData.currentLocationId }) != nil {
                            WeatherView(
                                location: WWLocation(
                                    savedLocation: self.savedLocations.first(where: { $0.id == self.sessionData.currentLocationId })!
                                )
                            )
                       }
                    }
                    BottomBar(safeAreaOffsets: geometry.safeAreaInsets)
                }.padding(.top, geometry.safeAreaInsets.top)

                CustomPopup(active: self.$appState.showingDayDetail) {
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
            .sheet(isPresented: self.$appState.showingSheet) {
                if (self.appState.sheetScreen == SheetScreen.locationsList) {
                    LocationsListView()
                        .environment(\.managedObjectContext, self.managedObjectContext)
                        .environmentObject(self.sessionData)
                        .environmentObject(self.searchManager)
                } else if (self.appState.sheetScreen == SheetScreen.settings) {
                    Settings()
                        .environment(\.managedObjectContext, self.managedObjectContext)
                        .environmentObject(self.sessionData)
                } else if self.appState.sheetScreen == SheetScreen.rainRadar {
                    NavigationView {
                        RainRadar(locationId: self.manager.simpleWeatherData!.location.id)
                            .navigationBarTitle(Text("Rain Radar"), displayMode: .inline)
                            .navigationBarItems(
                                leading: Button(action: {
                                    self.appState.hideSheet()
                                }) {
                                    Text("Done")
                                }
                            )
                    }.navigationViewStyle(StackNavigationViewStyle())
                } else {
                    Text("Unknown screen")
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, PersistentStorage.persistentContainer.viewContext)
            .environmentObject(SessionData())
            .environmentObject(AppState())
            .environment(\.colorScheme, .dark)
    }
}

extension WWLocation {
    init(savedLocation: SavedLocation) {
        self = WWLocation(
            id: Int64(savedLocation.id),
            name: savedLocation.name!,
            region: savedLocation.region!,
            state: savedLocation.state!,
            postcode: savedLocation.postcode!
        )
    }
}
