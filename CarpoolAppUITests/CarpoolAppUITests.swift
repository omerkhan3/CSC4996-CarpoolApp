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
        //XCUIApplication().launch()


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
    
    func tapButton(buttonName: String) {
        app.buttons[buttonName].tap()
    }
    
    

    
    func testLogin(){
        XCTAssertTrue(app.isDisplayingLogin)
        var exists = false
        app.buttons["loginButton"].tap()
        exists = app.alerts["Error!"].waitForExistence(timeout: 3)
        if (exists == true)
        {
            app.alerts["Error!"].buttons["OK"].tap()
            exists = false
        }
        let passwordField = app.secureTextFields["passwordField"]
        let emailField = app.textFields["emailField"]
        emailField.tap()
        emailField.typeText("server@server.com")
        passwordField.tap()
        passwordField.typeText("test124")
        app.buttons["loginButton"].tap()
        exists = app.alerts["Error!"].waitForExistence(timeout: 3)
        if (exists == true)
        {
            app.alerts["Error!"].buttons["OK"].tap()
            exists = false
        }
        passwordField.tap()
        passwordField.typeText("test123")
        app.buttons["loginButton"].tap()
        exists = app.alerts["Error!"].waitForExistence(timeout: 3)
        if (exists == true)
        {
            app.alerts["Error!"].buttons["OK"].tap()
            XCTFail()
            exists = false
        }

        XCTAssertTrue(app.isDisplayingDashboard)
    }
    
    
    
    func testRegister() {
        XCTAssertTrue(app.isDisplayingLogin)
        var exists = false
        app.buttons["registerButton"].tap()
        XCTAssertTrue(app.isDisplayingRegistration)
        app.buttons["signUpButton"].tap()
        exists = app.alerts["Error!"].waitForExistence(timeout: 3)
        if (exists == true)
        {
            app.alerts["Error!"].buttons["OK"].tap()
            exists = false
        }
        let email = self.randomString()+"@test.com"
        let password = self.randomString()
        app.textFields["firstName"].tap()
        app.textFields["firstName"].typeText("Automation")
        app.textFields["lastName"].tap()
        app.textFields["lastName"].typeText("Test")
        app.textFields["emailField"].tap()
        app.textFields["emailField"].typeText(email)
        app.textFields["phoneField"].tap()
        app.textFields["phoneField"].typeText("1234567890")
        app.secureTextFields["passwordField"].tap()
        app.secureTextFields["passwordField"].typeText(password)
        app.secureTextFields["confirmPasswordField"].tap()
        app.secureTextFields["confirmPasswordField"].typeText(password)
        
        app.buttons["signUpButton"].tap()
        exists = app.alerts["Success!"].waitForExistence(timeout: 3)
        if (exists == true)
        {
            app.alerts["Success!"].buttons["OK"].tap()
            exists = false
        }
        
        XCTAssertTrue(app.isDisplayingLogin)
        
        let passwordField = app.secureTextFields["passwordField"]
        let emailField = app.textFields["emailField"]
        emailField.tap()
        emailField.typeText(email)
        passwordField.tap()
        passwordField.typeText(password)
        app.buttons["loginButton"].tap()
        exists = app.alerts["Error!"].waitForExistence(timeout: 3)
        if (exists == true)
        {
            app.alerts["Error!"].buttons["OK"].tap()
            XCTFail()
            exists = false
        }
        XCTAssertTrue(app.isDisplayingDashboard)
    }
    
    func testEditProfile() {
        var exists = false
        
        // Test login view is displayed
        XCTAssertTrue(app.isDisplayingLogin)
        
        // Test login
        let passwordField = app.secureTextFields["passwordField"]
        let emailField = app.textFields["emailField"]
        emailField.tap()
        emailField.typeText("server@server.com")
        passwordField.tap()
        passwordField.typeText("test123")
        app.buttons["loginButton"].tap()
        
        // Test dashboard is displayed
        XCTAssertTrue(app.isDisplayingDashboard)
        
        // Tap first navigation item (Hamburger Menu)
        app.navigationBars.buttons.element(boundBy: 0).tap()
        
        // Test sideMenuTableView without helper function
        let sideMenuTableView = app.tables["sideMenuTableView"]
        XCTAssertTrue(sideMenuTableView.exists)
        
        // Test sideMenuTableView with helper function
        XCTAssertTrue(app.isDisplayingSideMenu)
        
        // Tap row on table view with specific label (see string array for menu items)
        app.tables["sideMenuTableView"].staticTexts["User Profile"].tap()
        
        // Test Profile View Displayed
        XCTAssertTrue(app.isDisplayingProfile)
        
        // Test Edit Profile (First Name)
        app.buttons["editProfileButton"].tap()
        let firstNameTest = self.randomString()
//        let lastNameTest = self.randomString()
//        let emailAddressTest = self.randomString()+"@test.com"
//        let phoneTest = "12345678910"
//        let bioTest = randomString()
        
        // Edit first name field
        app.textFields["editFirstNameField"].tap()
        app.textFields["editFirstNameField"].doubleTap()
        app.textFields["editFirstNameField"].typeText(firstNameTest)
        app.buttons["editProfileSubmitButton"].tap()
        
        // Handle Success Alert
        exists = app.alerts["Success!"].waitForExistence(timeout: 3)
        if exists == true {
            app.alerts["Success!"].buttons["OK"].tap()
            exists = false
        }

        // Verify update successful visually & tap back
        sleep(3)
        // Tap first navigation item (Hamburger Menu)
        app.navigationBars.buttons.element(boundBy: 0).tap()
        sleep(2)
    }
    
    
    func testAddRoute()
    {
        var exists = false
        let passwordField = app.secureTextFields["passwordField"]
        let emailField = app.textFields["emailField"]
        emailField.tap()
        emailField.typeText("jim@gmail.com")
        passwordField.tap()
        passwordField.typeText("test123")
        app.buttons["loginButton"].tap()
        exists = app.alerts["Error!"].waitForExistence(timeout: 3)
        if (exists == true)
        {
            app.alerts["Error!"].buttons["OK"].tap()
            exists = false
        }
        XCTAssertTrue(app.isDisplayingDashboard)
        
        exists = app.alerts["Error!"].waitForExistence(timeout: 3)
        if (exists == true)
        {
            XCTFail()
        }
        app.navigationBars.buttons.element(boundBy: 0).tap()
        //XCTAssertTrue(app.isDisplayingSideMenu)
        // Tap row on table view
        
        
        app.tables["sideMenuTableView"].staticTexts["My Routes"].tap()
        app.textFields["routeName"].tap()
        app.textFields["routeName"].typeText("Automation Test")
        app.buttons["SAVE"].tap()
        exists = app.alerts["Error!"].waitForExistence(timeout: 3)
        if (exists == true)
        {
            app.alerts["Error!"].buttons["OK"].tap()
            exists = false
        }
        app.searchFields["Starting Location"].tap()
        app.searchFields["Starting Location"].typeText("Wayne State University, 42 W Warren Ave, Detroit, MI 48202, United States")
        app.searchFields["Starting Location"].firstMatch.tap()
        app.searchFields["Ending Location"].tap()
        app.searchFields["Ending Location"].typeText("University of Michigan, 530 S State St, Ann Arbor, MI 48109, United States")
        app.searchFields["Ending Location"].firstMatch.tap()
        app.textFields["arrivalTime1"].tap()
        app.datePickers["arrivalTime1"].adjust(toPickerWheelValue: "08:30 AM")
        app.textFields["arrivalTime2"].tap()
        app.datePickers["arrivalTime2"].adjust(toPickerWheelValue: "09:30 AM")
        app.textFields["departureTime1"].tap()
        app.datePickers["departureTime1"].adjust(toPickerWheelValue: "05:00 PM")
        app.textFields["departureTime2"].tap()
        app.datePickers["departureTime2"].adjust(toPickerWheelValue: "05:30 PM")
        
        app.buttons["SAVE"].tap()
        exists = app.alerts["Error!"].waitForExistence(timeout: 3)
        if (exists == true)
        {
            XCTFail()
        }
        
        
        
    }
    
}
