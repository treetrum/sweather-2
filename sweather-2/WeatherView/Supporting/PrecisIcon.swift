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
    
    let size: CGFloat
    let precisCode: String
    
    init(precisCode: String) {
        self.precisCode = precisCode
        self.size = UIScreen.main.bounds.height < 812 ? 120 : 150
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
