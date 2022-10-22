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
    @Environment(\.horizontalSizeClass) var sizeClass
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
            VStack {
                Spacer()
                VStack {
                    self.contents()
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(30)
                .frame(maxWidth: .infinity, alignment: .center)
                .background(
                    self.colorScheme == ColorScheme.dark
                    ? Color.init(red: 0.1, green: 0.1, blue: 0.1)
                    : Color.white
                )
                .cornerRadius(4)
                .padding(30)
                .shadow(radius: 10)
                Spacer()
            }
            .frame(minWidth: 0, maxWidth: 500, minHeight: 0, maxHeight: .infinity, alignment: .center)
        }
        .opacity(self.active ? 1 : 0)
        .animation(.spring().speed(2), value: active)
    }
}

struct CustomPopupPreviewTest: View {
    
    @State var isOpen = false;
    
    var body: some View {
        Group {
            VStack {
                Button("Open popup") {
                    isOpen.toggle()
                }
                CustomPopup(active: $isOpen) {
                    Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aliquam diam augue, hendrerit vitae orci quis, suscipit condimentum mi. Etiam eu massa lacus. Integer placerat nec lacus in malesuada. Duis ullamcorper eget orci fringilla accumsan. Praesent ullamcorper rhoncus felis ut fringilla. Mauris ut facilisis sapien, quis auctor elit. Sed mauris felis, pulvinar a justo at, tincidunt dapibus leo. Donec pellentesque auctor mauris, quis aliquet ")
                }
            }
        }
    }
}

struct CustomPopup_Previews: PreviewProvider {
    static var previews: some View {
        CustomPopupPreviewTest()
            .previewDisplayName("Interactable")
        CustomPopup(active: .constant(true)) {
            Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aliquam diam augue, hendrerit vitae orci quis, suscipit condimentum mi. Etiam eu massa lacus. Integer placerat nec lacus in malesuada. Duis ullamcorper eget orci fringilla accumsan. Praesent ullamcorper rhoncus felis ut fringilla. Mauris ut facilisis sapien, quis auctor elit. Sed mauris felis, pulvinar a justo at, tincidunt dapibus leo. Donec pellentesque auctor mauris, quis aliquet ")
        }.previewDisplayName("Always open")
    }
}
