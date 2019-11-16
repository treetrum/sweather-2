//
//  Loading.swift
//  sweather-2
//
//  Created by Sam Davis on 16/11/19.
//  Copyright © 2019 Sam Davis. All rights reserved.
//

import SwiftUI

struct Loading: View {
    var body: some View {
        VStack {
            Spacer()
            Text("Loading...")
            Spacer()
        }.foregroundColor(Color.white)
    }
}

struct Loading_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.blue
            Loading()
        }
    }
}
