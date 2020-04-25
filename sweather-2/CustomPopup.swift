//
//  CustomPopup.swift
//  sweather-2
//
//  Created by Sam Davis on 25/4/20.
//  Copyright © 2020 Sam Davis. All rights reserved.
//

import SwiftUI

struct CustomPopup<Content>: View where Content: View {
    
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @EnvironmentObject var appState: AppState
    @Binding var active: Bool

    let contents: () -> Content
    
    var background: some View {
        VStack {
            EmptyView()
        }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
            .background(Color.black.opacity(0.5))
            .onTapGesture {
                self.active = false
            }
    }

    var body: some View {
        ZStack {
            self.background
                .scaleEffect(1.25)
                .offset(y: self.active ? 0 : -20)
                .animation(Animation.spring())
            VStack {
                Spacer()
                VStack {
                    contents().animation(nil)
                }
                    .padding(30)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .background(
                        colorScheme == ColorScheme.dark
                            ? Color.init(red: 0.1, green: 0.1, blue: 0.1)
                            : Color.white
                    )
                    .cornerRadius(4)
                    .padding(30)
                    .shadow(radius: 10)
                    .animation(nil)
                Spacer()
            }
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
        }
            .opacity(self.active ? 1 : 0)
            .offset(y: self.active ? 0 : 20)
            .animation(
                self.active
                    ? .spring(response: 0.25, dampingFraction: 0.66, blendDuration: 1)
                    : .easeOut(duration: 0.15)
            )
            
    }
}

struct CustomPopup_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CustomPopup(active: Binding.constant(true)) {
                Text("Hello")
            }.environment(\.colorScheme, .dark)
            CustomPopup(active: Binding.constant(true)) {
                Text("Hello")
            }.environment(\.colorScheme, .light)
        }
            .edgesIgnoringSafeArea(.all)
    }
}
