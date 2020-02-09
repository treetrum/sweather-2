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
    @ObservedObject var weatherDataManager: WeatherDataManager = WeatherDataManager()
    
    var body: some View {
        GeometryReader { geometry in
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

struct BackgroundGradient: View {
    
    @ObservedObject var manager = WeatherDataManager()
    var timePeriod: SWWeather.SWTimePeriod = .unknown

    var gradients: [[Color]] = [
        [Color.init(UIColor(hexString: "C92D2D")), Color.init(UIColor(hexString: "763BCD"))],
        [Color.init(UIColor(hexString: "46AEF3")), Color.init(UIColor(hexString: "910DA7"))],
        [Color.init(UIColor(hexString: "FFCB41")), Color.init(UIColor(hexString: "FB6914"))],
        [Color.init(UIColor(hexString: "FB6914")), Color.init(UIColor(hexString: "B300AC"))],
        [Color.init(UIColor(hexString: "272394")), Color.init(UIColor(hexString: "16A2FF"))],
        [Color.init(UIColor(hexString: "C92D2D")), Color.init(UIColor(hexString: "763BCD"))]
    ]
    
    init(manager: WeatherDataManager) {
        self.manager = manager;
        if let weatherData = manager.simpleWeatherData {
            self.timePeriod = weatherData.getTimePeriod()
        }
    }
    
    var body: some View {
        ZStack {
            ForEach(self.gradients.indices) { index in
                LinearGradient(
                    gradient: Gradient(colors: self.gradients[index]),
                    startPoint: UnitPoint(x: 0, y: 0),
                    endPoint: UnitPoint(x: 1, y: 1)
                )
                    .opacity(index == self.timePeriod.rawValue ? 1 : 0)
                    .animation(
                        Animation.easeInOut(duration: 1).delay(index == self.timePeriod.rawValue ? 0 : 1)
                    )
                    .zIndex(index == self.timePeriod.rawValue ? 100 : 0)
            }
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
