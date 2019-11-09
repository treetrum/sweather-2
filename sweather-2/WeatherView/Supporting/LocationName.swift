//
//  LocationName.swift
//  sweather-2
//
//  Created by Sam Davis on 9/11/19.
//  Copyright © 2019 Sam Davis. All rights reserved.
//

import SwiftUI

struct LocationName: View {
    
    @EnvironmentObject var sessionData: SessionData
    
    let location: WWLocation
    
    var body: some View {
        HStack {
            Spacer()
            if sessionData.viewingCurrentLocation {
                Image(systemName: "location.fill")
            }
            Text(location.name).font(.headline)
            Spacer()
        }
    }
}

struct LocationName_Previews: PreviewProvider {
    static var previews: some View {
        LocationName(
            location: SampleWeatherData().location
        ).environmentObject(SessionData(viewingCurrentLocation: true))
    }
}
