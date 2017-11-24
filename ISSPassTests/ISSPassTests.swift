//
//  ISSPassTests.swift
//  ISSPassTests
//
//  Created by TAPAN BISWAS on 11/21/17.
//  Copyright © 2017 TAPAN BISWAS. All rights reserved.
//

import XCTest
@testable import ISSPass

class ISSPassTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
    }
    
    
    func test_getDurationString() {
        //There are 2 possible values for 1st parameter and positive/negative value for 2nd parameter
        //Test 1: param1: true param2: -1000 -> result = ""
        var str = getDurationString(isFormatInSec: true, value: -1000)
        XCTAssert(str == "", "Expected empty string")
        
        //Test 2: param1: true param2: 5000 -> result = "5000 secs"
        str = getDurationString(isFormatInSec: true, value: 5000)
        XCTAssert(str == "5000 secs", "Expected 5000 secs")
        
        //Test 3: param1: true param2: 999999999999999999 -> result = "999999999999999999 secs"
        str = getDurationString(isFormatInSec: true, value: 999999999999999999)
        XCTAssert(str == "999999999999999999 secs", "Expected 999999999999999999 secs")
        
        //Test 4: param1: false param2: -1000 -> result = ""
        str = getDurationString(isFormatInSec: false, value: -1000)
        XCTAssert(str == "", "Expected empty string")
        
        //Test 5: param1: false param2: 5000 -> result = "5000"
        str = getDurationString(isFormatInSec: false, value: 5000)
        XCTAssert(str == "1h 23m 20s", "Expected 2 secs")
        
    }
    
    func test_monthColorWithInt() {
        //Possible param values: positive Int between 1-12, values other than 1-12
        //Test 1: param=1 -> result = UIColor.blue
        XCTAssert(monthColor(1) == UIColor.blue, "Expected UIColor.blue")
        
        //Test 2: param=12 -> result = UIColor.purple
        XCTAssert(monthColor(12) == UIColor.purple, "Expected UIColor.purple")
        
        //Test 3: param=0 -> result = UIColor.gray
        XCTAssert(monthColor(0) == UIColor.gray, "Expected UIColor.gray")

        //Test 3: param=13 -> result = UIColor.gray
        XCTAssert(monthColor(13) == UIColor.gray, "Expected UIColor.gray")

        //Test 3: param=-1 -> result = UIColor.gray
        XCTAssert(monthColor(-1) == UIColor.gray, "Expected UIColor.gray")
    }
    
    func test_monthColorWithDate() {
        //12 seperate test cases, 1 for each month to be simulated
        let dateFormatter = DateFormatter()
        let monthInterval:Double = 3600 * 24 * 30
        
        dateFormatter.dateFormat = "YYYY-MM-DD"
        //UIColor.blue, UIColor.green, UIColor.brown, UIColor.magenta, UIColor.yellow, UIColor.red, UIColor.black, UIColor.darkGray, UIColor.lightGray, UIColor.cyan, UIColor.orange, UIColor.purple
        
        //Test 1: Date with month value=1 -> result = UIColor.blue
        var date = dateFormatter.date(from: "2017-01-05")
        XCTAssert(monthColor(date!) == UIColor.blue, "Expected UIColor.blue")

        //Test 2: Date with month value=2 -> result = UIColor.green
        date = date?.addingTimeInterval(monthInterval)
        XCTAssert(monthColor(date!) == UIColor.green, "Expected UIColor.green")

        //Test 3: Date with month value=3 -> result = UIColor.green
        date = date?.addingTimeInterval(monthInterval)
        XCTAssert(monthColor(date!) == UIColor.brown, "Expected UIColor.brown")

        //Test 4: Date with month value=4 -> result = UIColor.green
        date = date?.addingTimeInterval(monthInterval)
        XCTAssert(monthColor(date!) == UIColor.magenta, "Expected UIColor.magenta")

        //Test 5: Date with month value=5 -> result = UIColor.green
        date = date?.addingTimeInterval(monthInterval)
        XCTAssert(monthColor(date!) == UIColor.yellow, "Expected UIColor.yellow")

        //Test 6: Date with month value=6 -> result = UIColor.green
        date = date?.addingTimeInterval(monthInterval)
        XCTAssert(monthColor(date!) == UIColor.red, "Expected UIColor.red")

        //Test 7: Date with month value=7 -> result = UIColor.green
        date = date?.addingTimeInterval(monthInterval)
        XCTAssert(monthColor(date!) == UIColor.black, "Expected UIColor.black")

        //Test 8: Date with month value=8 -> result = UIColor.green
        date = date?.addingTimeInterval(monthInterval)
        XCTAssert(monthColor(date!) == UIColor.darkGray, "Expected UIColor.darkGray")

        //Test 9: Date with month value=9 -> result = UIColor.green
        date = date?.addingTimeInterval(monthInterval)
        XCTAssert(monthColor(date!) == UIColor.lightGray, "Expected UIColor.lightGray")

        //Test 10: Date with month value=10 -> result = UIColor.green
        date = date?.addingTimeInterval(monthInterval)
        XCTAssert(monthColor(date!) == UIColor.cyan, "Expected UIColor.cyan")

        //Test 11: Date with month value=11 -> result = UIColor.green
        date = date?.addingTimeInterval(monthInterval)
        XCTAssert(monthColor(date!) == UIColor.orange, "Expected UIColor.orange")

        //Test 12: Date with month value=12 -> result = UIColor.green
        date = date?.addingTimeInterval(monthInterval)
        XCTAssert(monthColor(date!) == UIColor.purple, "Expected UIColor.purple")
    }
}
