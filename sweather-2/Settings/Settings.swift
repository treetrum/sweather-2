//
//  Settings.swift
//  sweather-2
//
//  Created by Sam Davis on 9/2/20.
//  Copyright © 2020 Sam Davis. All rights reserved.
//

import SwiftUI
import WeatherKit

struct NavigationButtonIcon: View {
    let iconName: String
    let colour: Color
    var body: some View {
        VStack {
            Image(systemName: iconName).foregroundColor(.white)
        }
        .font(.system(size: 14))
            .frame(width: 25, height: 25)
            .background(self.colour)
            .cornerRadius(4)
            .padding(.vertical, 5)
    }
}

struct Settings: View {
    
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) var managedObjectContext
    @EnvironmentObject var sessionData: SessionData
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    @State var showShareSheet: Bool = false
    
    @State var attribution: WeatherAttribution?
    
    var appInfo: some View {
    
        VStack(spacing: 10) {
            Text("Sweather \(UIApplication.appVersion!) (\(UIApplication.appBuildNumber!))").font(.headline)
            Text("Some data provided by [WillyWeather](https://www.willyweather.com.au/)")
                .multilineTextAlignment(.center)
        }
        .padding(.top, 30)
        .frame(maxWidth: .infinity, alignment: .center)
        .task {
            Task {
                if attribution == nil {
                    let weatherService = WeatherService()
                    let attribution = try! await weatherService.attribution
                    self.attribution = attribution
                }
            }
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    NavigationLink(destination: CustomIconPicker()) {
                        HStack {
                            NavigationButtonIcon(iconName: "photo", colour: .blue)
                            Text("App Icon")
                        }
                    }
                }

                Section( footer: appInfo ) {
                    Button(action: { self.showShareSheet = true }) {
                        HStack {
                            NavigationButtonIcon(iconName: "square.and.arrow.up", colour: .green)
                            Text("Share App")
                        }
                    }
                    Button(action: { UIApplication.shared.open(URL(string: "mailto:sam@sjd.co")!) }) {
                        HStack {
                            NavigationButtonIcon(iconName: "quote.bubble", colour: .green)
                            Text("Leave Feedback")
                        }
                    }
                    Button(action: {
                        UIApplication.shared.open(URL(string: "https://sweather.sjd.co/privacy")!)
                    }) {
                        HStack {
                            NavigationButtonIcon(iconName: "lock", colour: .purple)
                            Text("Privacy Policy")
                        }
                    }
                    Button(action: {
                        UIApplication.shared.open(URL(string: "https://sweather.sjd.co/terms")!)
                    }) {
                        HStack {
                            NavigationButtonIcon(iconName: "doc.text", colour: .purple)
                            Text("Terms of Use")
                        }
                    }
                }
            }
            .foregroundColor(colorScheme == .dark ? .white : .black)
            .listStyle(GroupedListStyle())
            .navigationBarTitle(Text("Settings"), displayMode: .inline)
            .navigationBarItems(
                leading: Button(action: closeSheet) {
                    Text("Done")
                })
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(isPresented: self.$showShareSheet) {
            ShareSheet(activityItems: [URL(string: "https://apps.apple.com/au/app/sweather/id1238159259")!])
        }
    }
    
    func closeSheet() {
        self.presentationMode.wrappedValue.dismiss()
    }
}

struct Settings_Previews: PreviewProvider {
    static var previews: some View {
        Settings()
    }
}


extension UIApplication {
    static var appVersion: String? {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }
    static var appBuildNumber: String? {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String
    }
}


struct ShareSheet: UIViewControllerRepresentable {
    typealias Callback = (_ activityType: UIActivity.ActivityType?, _ completed: Bool, _ returnedItems: [Any]?, _ error: Error?) -> Void
      
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil
    let excludedActivityTypes: [UIActivity.ActivityType]? = nil
    let callback: Callback? = nil
      
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: applicationActivities)
        controller.excludedActivityTypes = excludedActivityTypes
        controller.completionWithItemsHandler = callback
        return controller
    }
      
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // nothing to do here
    }
}
