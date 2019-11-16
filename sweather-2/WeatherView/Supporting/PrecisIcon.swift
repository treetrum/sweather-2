//
//  PrecisIcon.swift
//  sweather-2
//
//  Created by Sam Davis on 9/11/19.
//  Copyright © 2019 Sam Davis. All rights reserved.
//

import SwiftUI

struct PrecisIcon: View {
    
    @Environment(\.colorScheme) var colorScheme: ColorScheme

    let precisCode: String
    
    var body: some View {
        Image(precisCode).resizable().frame(width: 200, height: 200)
    }
}

struct PrecisIcon_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.blue
            PrecisIcon(precisCode: SampleWeatherData().getPrecisImageCode())
        }
    }
}
