//
//  RainRadarButton.swift
//  sweather-2
//
//  Created by Sam Davis on 29/6/20.
//  Copyright © 2020 Sam Davis. All rights reserved.
//

import SwiftUI

struct RainRadarButton: View {
    @EnvironmentObject var appState: AppState
    var body: some View {
        Button(action: {
            self.appState.showSheet(.rainRadar)
        }) {
            Text("Rain Radar")
                .padding()
                .frame(maxWidth: .infinity)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.white, lineWidth: 1)
            )
                .padding(.horizontal)
        }.foregroundColor(.white)
    }
}

struct RainRadarButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Spacer()
            RainRadarButton()
            Spacer()
        }.background(Color.blue)
    }
}
