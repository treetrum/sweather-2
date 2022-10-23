//
//  LocationRow.swift
//  sweather-2
//
//  Created by Sam Davis on 6/5/20.
//  Copyright © 2020 Sam Davis. All rights reserved.
//

import SwiftUI

struct LocationRow: View {
    
    var location: WWLocation
    
    init(_ location: SavedLocation) {
        self.location = WWLocation(savedLocation: location)
    }
    
    init(_ location: WWLocation) {
        self.location = location
    }

    var body: some View {
        Text("\(location.name), \(location.postcode)")
    }

}

struct LocationRow_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            List {
                Section() {
                    LocationRow(SampleWeatherData.fromWW.location)
                }
            }
            .navigationBarTitle("Locations", displayMode: .inline)
            .listStyle(GroupedListStyle())
        }
    }
}
