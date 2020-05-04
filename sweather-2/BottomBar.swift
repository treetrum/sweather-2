//
//  Bottombar.swift
//  sweather-2
//
//  Created by Sam Davis on 16/11/19.
//  Copyright © 2019 Sam Davis. All rights reserved.
//

import SwiftUI

struct BottomBar: View {
    
    @Binding var showingModal: Bool
    @Binding var showingListView: Bool
    @Binding var showingSettings: Bool
    var safeAreaOffsets: EdgeInsets
    
    var body: some View {
        VStack {
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color.white.opacity(0.5))
                .padding(.all, 0)
            HStack {
                Button(action: {
                    self.showingModal = true
                    self.showingListView = true
                    self.showingSettings = false
                }) {
                    Image(systemName: "list.dash").foregroundColor(Color.white).padding(.all)
                }
                Spacer()
                Button(action: {
                    self.showingModal = true
                    self.showingSettings = true
                    self.showingListView = false 
                }) {
                    Image(systemName: "gear").foregroundColor(Color.white).padding(.all)
                }
            }.padding(.bottom, safeAreaOffsets.bottom)
        }.padding([.leading, .trailing]).padding(.top, 0)
    }
}

struct BottomBar_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                BackgroundGradient()
                BottomBar(
                    showingModal: .constant(false),
                    showingListView: .constant(false),
                    showingSettings: .constant(false),
                    safeAreaOffsets: geometry.safeAreaInsets
                )
            }.edgesIgnoringSafeArea(.all)
        }
    }
}
