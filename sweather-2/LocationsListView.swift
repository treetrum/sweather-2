//
//  LocationsListView.swift
//  sweather-2
//
//  Created by Sam Davis on 29/10/19.
//  Copyright © 2019 Sam Davis. All rights reserved.
//

import SwiftUI
import GoogleMobileAds

struct LocationsListView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) var managedObjectContext
    @EnvironmentObject var sessionData: SessionData
    
    @FetchRequest( entity: SavedLocation.entity(), sortDescriptors: [] ) var savedLocations: FetchedResults<SavedLocation>
    @State var showingAddLocationView: Bool = false

    var body: some View {
        NavigationView {
            List {
                Section {
                    Button(action: selectCurrentLocation ) {
                        HStack {
                            NavigationButtonIcon(iconName: "location.fill", colour: .green)
                            Text("Current location")
                        }
                    }
                }
                Section {
                    ForEach(savedLocations, id: \.id) { location in
                        Button(action: { self.handleLocationPress(location) }) {
                            LocationRow(location)
                        }
                    }.onDelete { (offsets: IndexSet) in
                        for index in offsets {
                            let location = self.savedLocations[index]
                            self.managedObjectContext.delete(location)
                        }
                    }
                }
                if !self.sessionData.hasAdRemovalSubscription {
                    Banner().frame(height: kGADAdSizeBanner.size.height).listRowInsets(EdgeInsets())
                }
            }
            .listStyle(GroupedListStyle())
            .navigationBarTitle(Text("Locations"), displayMode: .inline)
            .navigationBarItems(
                leading: Button(action: closeSheet) {
                    Text("Done")
                },
                trailing: Button(action: showAddLocationView, label: {
                    Image(systemName: "plus").padding(.all)
                }))
            .sheet(isPresented: self.$showingAddLocationView) {
                AddLocationView().environment(\.managedObjectContext, self.managedObjectContext)
            }
        }
    }
    
    func showAddLocationView() {
        self.showingAddLocationView = true;
    }
    
    func closeSheet() {
        self.presentationMode.wrappedValue.dismiss()
    }
    
    func selectCurrentLocation() {
        sessionData.viewingCurrentLocation = true
        closeSheet()
    }
    
    func handleLocationPress(_ savedLocation: SavedLocation) {
        let location = WWLocation(savedLocation: savedLocation)
        sessionData.viewingCurrentLocation = false
        sessionData.currentLocationId = location.id
        closeSheet()
    }
}

struct LocationsListView_Previews: PreviewProvider {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    static var previews: some View {
        LocationsListView()
    }
}
