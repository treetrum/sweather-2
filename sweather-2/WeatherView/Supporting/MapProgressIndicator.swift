//
//  MapProgressIndicator.swift
//  sweather-2
//
//  Created by Sam Davis on 26/4/20.
//  Copyright © 2020 Sam Davis. All rights reserved.
//

import SwiftUI

struct MapProgressIndicator: View {
    let progress: Double
    var body: some View {
        VStack {
            GeometryReader { (geo: GeometryProxy) in
                ZStack(alignment: .leading) {
                    Rectangle().frame(maxWidth: geo.size.width, maxHeight: 3).foregroundColor(Color.white.opacity(0))
                    Rectangle().frame(maxWidth: geo.size.width * CGFloat(self.progress), maxHeight: 3).foregroundColor(Color.blue)
                        .animation(progress != 0 ? .default : nil, value: progress)
                }
            }.frame(height: 3)
        }
    }
}

struct MapProgressIndicator_Previews: PreviewProvider {
    static var previews: some View {
        MapProgressIndicator(progress: 0.5)
    }
}
