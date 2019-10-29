//
//  AddLocationView.swift
//  sweather-2
//
//  Created by Sam Davis on 29/10/19.
//  Copyright © 2019 Sam Davis. All rights reserved.
//

import SwiftUI

struct AddLocationView: View {
    @State var searchValue: String = "";
    @State var searching: Bool = false;
    
    @ObservedObject var searchManager = SearchDataManger()
    
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) var managedObjectContext

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    TextField("Location", text: self.$searchValue)
                    Button(action: handleSearch) {
                        Text("Search")
                    }
                }.padding(.all, 16).padding(.bottom, 0)
                List {
                    ForEach(self.searchManager.results, id: \.id) { (location: WWLocation) in
                        Button(action: {
                            
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
                            
                        }) {
                            LocationRow(location)
                        }
                    }
                }
            }
            .navigationBarTitle("Add Location", displayMode: .inline)
        }
        
    }
    
    func handleSearch() {
        self.searching = true
        self.searchManager.search(query: searchValue)
    }
}


struct AddLocationView_Previews: PreviewProvider {
    static var previews: some View {
        AddLocationView()
    }
}
