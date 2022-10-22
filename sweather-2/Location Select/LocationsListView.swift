//
//  LocationsListView.swift
//  sweather-2
//
//  Created by Sam Davis on 29/10/19.
//  Copyright © 2019 Sam Davis. All rights reserved.
//

import SwiftUI

let MAX_NUMBER_CUSTOM_LOCATIONS = 5;

struct LocationsListView: View {
    
    @EnvironmentObject var searchManager: LocationSearchManager
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) var managedObjectContext
    @ObservedObject var sessionData = SessionData.shared
    
    @FetchRequest( entity: SavedLocation.entity(), sortDescriptors: [] ) var savedLocations: FetchedResults<SavedLocation>
    @State var showingAddLocationView: Bool = false
    
    @State var showAlert = false
    @State var alertTitle = ""
    @State var alertBody = ""

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
                Section(footer: Text("\(self.savedLocations.count) of 5 saved locations used")) {
                    ForEach(savedLocations, id: \.id) { location in
                        Button(action: { self.handleLocationPress(location) }) {
                            LocationRow(location)
                        }.accessibility(label: Text(location.name!))
                    }.onDelete { (offsets: IndexSet) in
                        self.handleDelete(offsets)
                    }
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
                AddLocationView()
                    .environment(\.managedObjectContext, self.managedObjectContext)
                    .environmentObject(self.searchManager)
            }
            .alert(isPresented: self.$showAlert) { () -> Alert in
                Alert(
                    title: Text(self.alertTitle),
                    message: Text(self.alertBody),
                    dismissButton: .default(Text("Got it!"))
                )
            }
        }.navigationViewStyle(StackNavigationViewStyle())
    }
    
    func showAddLocationView() {
        if (self.savedLocations.count < MAX_NUMBER_CUSTOM_LOCATIONS) {
            self.showingAddLocationView = true;
        } else {
            self.showAlert = true;
            self.alertTitle = "Limit reached"
            self.alertBody = "You can only add \(MAX_NUMBER_CUSTOM_LOCATIONS) saved locations. Please remove an existing location before adding another."
        }
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
    
    func handleDelete(_ offsets: IndexSet) {
        for index in offsets {
            let location = self.savedLocations[index]
            self.managedObjectContext.delete(location)
            do {
                self.sessionData.viewingCurrentLocation = true
                try self.managedObjectContext.save()
            } catch {
                print("[DB] Error when saving after deleting from DB")
            }
        }
    }
}

struct LocationsListView_Previews: PreviewProvider {
    
    let context = PersistentStorage.container.viewContext

    static var previews: some View {
        LocationsListView()
    }
}
