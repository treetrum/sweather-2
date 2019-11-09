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
        ZStack {
            if colorScheme == .dark {
                Image(precisCode)
            } else {
                Image(precisCode).colorInvert()
            }
        }
    }
}

struct PrecisIcon_Previews: PreviewProvider {
    static var previews: some View {
        PrecisIcon(precisCode: SampleWeatherData().getPrecisImageCode())
    }
}
