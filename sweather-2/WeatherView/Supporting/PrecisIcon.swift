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
    @Environment(\.horizontalSizeClass) var sizeClass
    
    let precisCode: String
    
    var size: CGFloat {
        get {
            if isIpad(sizeClass) {
                return 175
            } else {
                return UIScreen.main.bounds.height < 812 ? 120 : 150
            }
        }
    }
    
    var body: some View {
        Image(precisCode).resizable().frame(width: self.size, height: self.size)
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
