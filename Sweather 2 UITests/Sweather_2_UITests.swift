//
//  Sweather_2_UITests.swift
//  Sweather 2 UITests
//
//  Created by Sam Davis on 16/5/20.
//  Copyright © 2020 Sam Davis. All rights reserved.
//

import XCTest

class Sweather_2_UITests: XCTestCase {
    
    var app = XCUIApplication()

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
        setupSnapshot(app)
        app.launchArguments.append("--UITests")
        app.launchArguments.append("--no-ads")
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        app.launch()
        
        // Sydney Weather View
        app.buttons["list.dash"].tap()
        let sydneyButton = app.tables/*@START_MENU_TOKEN@*/.buttons["Sydney"]/*[[".cells.buttons[\"Sydney\"]",".buttons[\"Sydney\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        sydneyButton.tap()
        snapshot("01-weather")
        app.swipeUp()
        snapshot("02-weather-days")
        
        // Radar
        app.otherElements.buttons["Rain Radar"].tap()
        snapshot("03-rain-radar")
        app.navigationBars["Rain Radar"].buttons["Done"].tap()
        
        // Add a bunch of locations
        app.buttons["list.dash"].tap()
        let addLocationButton = app.navigationBars["Locations"].buttons["plus"]
        let addLocationTextField = app.textFields["Location"]
        
            // Add Melbourne
            addLocationButton.tap()
            addLocationTextField.tap()
            app.typeText("Melbourne")
            app.tables.buttons["Melbourne, 3000"].tap()
            
            // Add Brisbane
            addLocationButton.tap()
            addLocationTextField.tap()
            app.typeText("Brisbane")
            app.tables.buttons["Brisbane, 4000"].tap()
            
            // Add Brisbane
            addLocationButton.tap()
            addLocationTextField.tap()
            app.typeText("Adelaide")
            app.tables.buttons["Adelaide, 5000"].tap()
            
            // Add Perth
            addLocationButton.tap()
            addLocationTextField.tap()
            app.typeText("Perth")
            app.tables/*@START_MENU_TOKEN@*/.buttons["Perth, 6000"]/*[[".cells.buttons[\"Perth, 6000\"]",".buttons[\"Perth, 6000\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
            
        snapshot("04-locations")
        app.navigationBars["Locations"].buttons["Done"].tap()
                

        // App Icons
        app.buttons["gear"].tap()
        let tablesQuery = app.tables
        tablesQuery/*@START_MENU_TOKEN@*/.buttons["App Icon"]/*[[".cells.buttons[\"App Icon\"]",".buttons[\"App Icon\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        snapshot("05-app-icons")
        
    }

}
