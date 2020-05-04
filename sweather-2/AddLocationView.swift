//
//  AddLocationView.swift
//  sweather-2
//
//  Created by Sam Davis on 29/10/19.
//  Copyright © 2019 Sam Davis. All rights reserved.
//

import SwiftUI

struct AddLocationView: View {
    
    @ObservedObject var searchManager = LocationSearchManager()
    
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) var managedObjectContext

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    TextField("Location", text: $searchManager.inputValue)
                        .padding(10)
                        .background(Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.02)))
                        .cornerRadius(10)
                    Button(action: handleCancel) {
                        Text("Cancel")
                    }
                }.padding([.leading, .trailing, .top])
                List {
                    ForEach(self.searchManager.results, id: \.id) { (location: WWLocation) in
                        Button(action: { self.handleLocationSelect(location) }) {
                            LocationRow(location)
                        }
                    }
                }.listStyle(GroupedListStyle())
            }
            .navigationBarTitle("Add Location", displayMode: .inline)
            .navigationBarItems(
                leading: Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Done")
                }
            )
        }
        
    }
    
    func handleLocationSelect(_ location: WWLocation) {
        let newLocation = SavedLocation(context: self.managedObjectContext)
        newLocation.id = Int16(location.id)
        newLocation.name = location.name
        newLocation.postcode = location.postcode
        newLocation.region = location.region
        newLocation.state = location.state
        do {
            try self.managedObjectContext.save()
        } catch {
            print(error)
        }
        self.presentationMode.wrappedValue.dismiss()
    }
    
    func handleCancel() {
        self.searchManager.inputValue = ""
    }
}


struct AddLocationView_Previews: PreviewProvider {
    static var previews: some View {
        AddLocationView().environment(\.colorScheme, .light)
    }
}
