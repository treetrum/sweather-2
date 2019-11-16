//
//  Bottombar.swift
//  sweather-2
//
//  Created by Sam Davis on 16/11/19.
//  Copyright © 2019 Sam Davis. All rights reserved.
//

import SwiftUI

struct BottomBar: View {
    
    @Binding var showingListView: Bool
    var safeAreaOffsets: EdgeInsets
    
    var body: some View {
        VStack {
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color.white)
                .padding(.all, 0)
                .opacity(0.5)
            HStack {
                Button(action: {
                    self.showingListView = true
                }, label: {
                    Image(systemName: "list.dash").foregroundColor(Color.white).padding(.all)
                })
                Spacer()
                Image(systemName: "exclamationmark.triangle").foregroundColor(Color.white).padding(.all)
            }.padding(.bottom, safeAreaOffsets.bottom)
        }.padding([.leading, .trailing]).padding(.top, 0)
    }
}

struct BottomBar_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                BackgroundGradient()
                BottomBar(showingListView: .constant(false), safeAreaOffsets: geometry.safeAreaInsets)
            }.edgesIgnoringSafeArea(.all)
        }
    }
}
