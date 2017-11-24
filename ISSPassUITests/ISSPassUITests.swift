//
//  ISSPassUITests.swift
//  ISSPassUITests
//
//  Created by TAPAN BISWAS on 11/21/17.
//  Copyright © 2017 TAPAN BISWAS. All rights reserved.
//

import XCTest

class ISSPassUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    
    func testISSPass() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // This is not an exhaustive test for the app, but just a subset of the functionality,
        // that includes navigation and loading of data.

        // To make this test work quickly, disable the Refresh Control on tableView, otherwise
        // it takes forever as the UITest keeps waiting for the App to idle.
        // Comment out line=100 in MainViewController.swift and rerun these tests
        
        // Absolute basic functionality test. We are not checking for cell level data and validation
        // of the same. Time permits, I can write those as well.
        
        let app = XCUIApplication()
        
        XCTAssert(app.buttons.count == 1, "Test 1: Expect only 1 button on first screen")
        
        app.buttons["Launch Demo"].tap()
        
        let loadDataButton = app.buttons["Load Data"]
        let clearButton = app.buttons["Clear"]
        let incrementButton = app.steppers.buttons["Increment"]
        let decrementButton = app.steppers.buttons["Decrement"]
        let table = app.tables.containing(.other, identifier:"Date-Time")
        var numRecsLabel = app.staticTexts.element(matching: .any, identifier: "Display 5 records").label
                
        XCTAssert(numRecsLabel.contains("5"), "Test 2: Expected default value of 5")
        
        loadDataButton.tap()
        XCTAssert(table.cells.count == 5, "Test 3: Expected 5 rows")

        clearButton.tap()
        XCTAssert(table.cells.count == 0, "Test 4: Expected 0 rows")

        incrementButton.tap()
        numRecsLabel = app.staticTexts.element(matching: .any, identifier: "Display 6 records").label
        XCTAssert(numRecsLabel.contains("6"), "Test 5: Expected 6 after increment")

        decrementButton.tap()
        numRecsLabel = app.staticTexts.element(matching: .any, identifier: "Display 5 records").label
        XCTAssert(numRecsLabel.contains("5"), "Test 6: Expected 5 after decrement")

        //Increase the number of Records to 8 and load again
        incrementButton.tap() //number of record = 6
        incrementButton.tap() //number of record = 7
        incrementButton.tap() //number of record = 8

        loadDataButton.tap()
        XCTAssert(table.cells.count == 8, "Test 7: Expected 8 rows")

        clearButton.tap()
        XCTAssert(table.cells.count == 0, "Test 8: Expected 0 rows")

        XCUIApplication().navigationBars["ISSPass.MainView"].buttons["Back"].tap()
        XCTAssert(app.buttons.count == 1, "Test 9: Expect only 1 button on first screen")
    }
    
}
