//
//  AppState.swift
//  sweather-2
//
//  Created by Sam Davis on 24/6/20.
//  Copyright © 2020 Sam Davis. All rights reserved.
//

import Foundation

enum SheetScreen {
    case locationsList
    case settings
    case rainRadar
}

class AppState: ObservableObject {
    
    // MARK: - App Sheet
    
    @Published var showingSheet: Bool = false
    @Published var sheetScreen: SheetScreen = .locationsList
    
    func showSheet(_ screen: SheetScreen) {
        showingSheet = true
        sheetScreen = screen
    }
    
    func hideSheet() {
        showingSheet = false
    }
    
    // MARK: - Day Detail
    
    @Published var showingDayDetail: Bool = false
    @Published var dayDetailDay: SWWeather.Day? = nil
    
    func showDayDetail(_ day: SWWeather.Day) {
        showingDayDetail = true
        dayDetailDay = day
    }
    
    func hideDayDetail() {
        showingDayDetail = false
        dayDetailDay = nil
    }
    
}

