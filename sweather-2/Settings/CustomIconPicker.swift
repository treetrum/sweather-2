//
//  CustomIconPicker.swift
//  sweather-2
//
//  Created by Sam Davis on 9/2/20.
//  Copyright © 2020 Sam Davis. All rights reserved.
//

import SwiftUI

struct CustomIconPicker: View {
    
    @State var currentIconName = UIApplication.shared.alternateIconName
    
    struct IconSet {
        let name: String
        let keys: [String]
    }
    
    let icons = [
        IconSet(name: "Default", keys: ["default-snow", "default-sun", "default"]),
        IconSet(name: "Purple Blue", keys: ["custom-1-snow", "custom-1-sun", "custom-1"]),
        IconSet(name: "Blue", keys: ["custom-2-snow", "custom-2-sun", "custom-2"]),
        IconSet(name: "Gold", keys: ["custom-3-snow", "custom-3-sun", "custom-3"]),
        IconSet(name: "Purply", keys: ["custom-4-snow", "custom-4-sun", "custom-4"]),
        IconSet(name: "Night", keys: ["custom-5-snow", "custom-5-sun", "custom-5"]),
        IconSet(name: "Snowstorm", keys: ["custom-6-snow", "custom-6-sun", "custom-6"])
    ]
    
    let size: CGFloat = 50
    
    var body: some View {
        List {
            Section {
                ForEach(icons, id: \.name) { (icon: IconSet) in
                    HStack {
                        Text(icon.name).font(.headline)
                        Spacer()
                        HStack {
                            ForEach(icon.keys.indices) { index in
                                Image(icon.keys[index])
                                .resizable()
                                .frame(width: self.size, height: self.size)
                                .cornerRadius(11)
                                .shadow(radius: 1)
                                .overlay(
                                    self.currentIconName ?? "default" == icon.keys[index]
                                        ? RoundedRectangle(cornerRadius: 11).stroke(Color.blue, lineWidth: 3)
                                        : RoundedRectangle(cornerRadius: 11).stroke(Color.blue, lineWidth: 0)
                                )
                                .padding(.horizontal, 2)
                                .onTapGesture { handleIconSelect(icon, index: index) }
                            }
                            
                        }
                        
                    }.padding(.vertical, 5)
                }
            }
        }
        .listStyle(GroupedListStyle())
        .navigationBarTitle("App Icon", displayMode: .inline)
    }
    
    func handleIconSelect(_ icon: IconSet, index: Int) {
        let key = icon.keys[index]
        if key == "default" {
            UIApplication.shared.setAlternateIconName(nil, completionHandler: { error in
                if let error = error {
                    print(error)
                    return
                }
                self.currentIconName = nil
            })
        } else {
            UIApplication.shared.setAlternateIconName(key, completionHandler: { error in
                if let error = error {
                    print(error)
                    return
                }
                self.currentIconName = key
            })
        }
    }
}

struct CustomIconPicker_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CustomIconPicker()
        }
    }
}
