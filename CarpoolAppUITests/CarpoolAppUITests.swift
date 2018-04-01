//
//  CarpoolAppUITests.swift
//  CarpoolAppUITests
//
//  Created by Omer  Khan on 4/1/18.
//  Copyright © 2018 CSC 4996. All rights reserved.
//

import XCTest

class CarpoolAppUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        
        app = XCUIApplication()
        app.launch()
        sleep(1)
    // XCUIApplication().launch()


        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func randomString() -> String {
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = 7
        
        var randomString = ""
        
        for _ in 0 ..< 7 {
            let rand = arc4random_uniform(UInt32(len))
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        
        return randomString
    }
    
    func testLogin(){
        app.buttons["loginButton"].tap()
        app.alerts["Error!"].buttons["OK"].tap()
        let passwordField = app.secureTextFields["passwordField"]
        let emailField = app.textFields["emailField"]
        emailField.tap()
        emailField.typeText("server@server.com")
        passwordField.tap()
        passwordField.typeText("test124")
        app.buttons["loginButton"].tap()
        app.alerts["Error!"].buttons["OK"].tap()
        passwordField.tap()
        passwordField.typeText("test123")
        app.buttons["loginButton"].tap()
        XCTAssertTrue(app.isDisplayingDashboard)
    }
    
    
    func testRegister() {
        let userName = self.randomString()
        let password = self.randomString()
        
        app.buttons["registerButton"].tap()
        
        app.textFields["firstName"].tap()
        app.textFields["firstName"].typeText("Steve")
    }
    
    
    
}
